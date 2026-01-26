#INCLUDE "tfata02.ch"
#Include 'rwmake.ch'
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTFATA02   บAutor  ณEWERTON C TOMAZ     บ Data ณ  01/08/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera NF baseada no pedido automaticamente                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Template Function TFATA02()

CHKTEMPLATE("DCM")  

Public _cMarca := GetMark()
Private cQueryCad := ""
Private cPerg     := Padr("MT460A",Len(SX1->X1_GRUPO))
Private cPedS     := CriaVar("C6_NUM")
Private aPedS     := {}
Private _aPedAgl  := {}
Private _lVerAglut:= .F.
Private aFields   := {}
Private cArq      := ''
Private _cIndex   := ''
Private oGeraNf

cSerie  := GetMV('MV_SERIENF')+Space(3-Len(GetMV('MV_SERIENF')))
If cArq <> ''
   DbSelectArea("TC9")
   DbCloseArea()
   FErase(cArq+OrdBagExt())
   FErase(_cIndex+ordbagext())
   _cIndex := ''
   cArq    := ''
EndIf

@ 200,001 TO 380,380 DIALOG oGeraNf TITLE OemToAnsi(STR0001) //"Geracao de Nf Automatica"
@ 003,005 TO 085,187
@ 010,018 Say STR0002 SIZE 150,010 //"Este programa ira gerar N.f. conforme pedido digitado."
@ 028,018 Say STR0003 SIZE 150,010 //"Nr.Pedido:"
@ 028,048 Get cPeds   SIZE 010,050 object oPeds F3 "SC5"
@ 039,018 Say STR0004 //"Serie NF :"
@ 039,048 Get cSerie Valid ValidaSerie()
@ 065,018 BMPBUTTON TYPE 11 ACTION Multi()
@ 065,048 BMPBUTTON TYPE 05 ACTION Pergunte(cPerg,.T.)
@ 065,118 BMPBUTTON TYPE 01 ACTION Processa({||MaRwProc()})
@ 065,148 BMPBUTTON TYPE 02 ACTION oGeraNf:End()
oPeds:SetFocus()
Activate Dialog oGeraNf Centered

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValidaSerie บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidaSerie()
If Empty(Tabela('01',cSerie,.F.))
   MsgStop(STR0005) //'Serie Invalida !'
   Return(.F.)
Endif
Return(.T.)   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณConfirmaProcบAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ConfirmaProc()
//If MsgYesNo('Confirma o Processamento ?','Gerar Notas','YESNO')
If MsgYesNo(STR0006) //"Confirma o Processamento ?"
   Processa({||MaRwProc()})
Endif   
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMaRwProc    บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MaRwProc()
/*
If GetMv('MV_BLOQFAT') = 'S'
   MsgStop('Faturamento bloqueado para geracao de notas de ocorrencia!'+Chr(13)+;
           'Em caso de Urgencia comunique o setor responsavel!')
   Return(.T.)
Endif
*/
                   
Local _nXGer
Local _nX

lAdiciona := .T.
APvlNfs   := {}
_aPedAgl  := {}
_cNota    := ''
_cNotaPri := ''      

cPedido := cPedS
cPedS   := CriaVar("C6_NUM")

If Len(aPedS) = 0
   AaDd(aPedS,cPedido)
   _lVerAglut := .F.  
Endif

Pergunte(Padr("MT460A",Len(SX1->X1_GRUPO)) ,.F.)

For _nX := 1 To Len(aPedS)

	cPedido := Upper( aPedS[_nX] ) 

	DbSelectArea("SC6")
	DbSetORder(1)
	If !DbSeek(xFilial("SC6")+cPedido)
       MsgStop(STR0007+cPedido+STR0008) //'Pedido '###' com problema, verifique !!!'
       If cArq <> ''
          DbSelectArea("TC9")
          DbCloseArea()
          FErase(cArq+OrdBagExt())
          FErase(_cIndex+ordbagext())
          _cIndex := ''
          cArq    := ''
       EndIf
       //T_TFATA02()        
	   Return(.T.)
	Endif

	ProcRegua(LastRec())

	While SC6->(! Eof()) .AND. SC6->C6_FILIAL == xFilial("SC6") .AND. SC6->C6_NUM == cPedido
	   
	    IncProc(STR0009) //"Gerando Nota Fiscal..."
       
    	DbSelectArea("SC9")
	    DbSetORder(1)
    	DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
    	
    	While SC9->(! Eof()) .AND. SC9->C9_FILIAL == xFilial("SC9") .AND. SC9->C9_PEDIDO == SC6->C6_NUM .AND. SC9->C9_ITEM == SC6->C6_ITEM
	       lAdiciona := .T.
    	   If ( SC9->C9_BLEST == "10" ) .Or.;
    	      !Empty(SC9->C9_BLEST) .Or.;
    	      !Empty(SC9->C9_BLCRED) .Or.;
    	      Empty(SC9->C9_BLPRE) .Or.;
    	      Empty(SC9->C9_BLCONF)
        	  lAdiciona := .F.
	       Endif
    	   If lAdiciona
        	  DbSelectArea("SB1")
		      DbSetOrder(1)
  		      DbSeek(xFilial("SB1")+SC9->C9_PRODUTO)
		  
			  DbSelectArea("SC5")
			  DbSetOrder(1)
			  DbSeek(xFilial("SC5")+SC9->C9_PEDIDO)
		
			  DbSelectArea("SC6")
			  dbSetOrder(1)
			  DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)
		
			  DbSelectArea("SB2")
			  DbSetOrder(1)
			  DbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL)
		
			  DbSelectArea("SF4")
			  DbSetOrder(1)
	 		  DbSeek(xFilial("SF4")+SC6->C6_TES)
		
			  DbSelectArea("SE4")
			  DbSetOrder(1)
			  DbSeek(xFilial("SE4")+SC5->C5_CONDPAG)
		
			  DbSelectarea("SC9")
			  nPrcVen := SC9->C9_PRCVEN
			  If ( SC5->C5_MOEDA != 1 )
		    	 nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,dDataBase)
			  EndIf
		        
		      If _lVerAglut	
  		         If AsCan(aPvlNfs,{|x|x[6]=C9_PRODUTO}) = 0
  			        aadd(aPvlNfs,{ C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_QTDLIB,nPrcVen,C9_PRODUTO,If(lQuery,F4ISS=="S",SF4->F4_ISS=="S"),	SC9->(RecNo()),	SC5->(RecNo()),	SC6->(RecNo()),SE4->(RecNo()),SB1->(RecNo()),SB2->(RecNo()),SF4->(RecNo()),C9_LOCAL,0})
    			 Else
  			        aPvlNfs[AsCan(aPvlNfs,{|x|x[6]=C9_PRODUTO}),4] += C9_QTDLIB
  			        AaDd(_aPedAgl,{C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_QTDLIB,;
		                  aPvlNfs[AsCan(aPvlNfs,{|x|x[6]=C9_PRODUTO}),1],;
  			              aPvlNfs[AsCan(aPvlNfs,{|x|x[6]=C9_PRODUTO}),2],;
  			              aPvlNfs[AsCan(aPvlNfs,{|x|x[6]=C9_PRODUTO}),3]})
  			     Endif
  			     _cCli := SC9->C9_CLIENTE
  			  Else
  			     aadd(aPvlNfs,{ C9_PEDIDO,C9_ITEM,C9_SEQUEN,C9_QTDLIB,nPrcVen,C9_PRODUTO,If(lQuery,F4ISS=="S",SF4->F4_ISS=="S"),	SC9->(RecNo()),	SC5->(RecNo()),	SC6->(RecNo()),SE4->(RecNo()),SB1->(RecNo()),SB2->(RecNo()),SF4->(RecNo()),C9_LOCAL,0})         
  			  Endif   
		
	       EndIf
    	   DbSelectarea("SC9")
	       DbSkip()
    	End   
		DbSelectArea('SC6')
		DbSkip()
	End
   
    If !_lVerAglut	
       If Len(aPvlNfs) <= GetMV('MV_NUMITEN')
          If Empty(_cNota)
             _cNota := GeraNota()
          Else   
             GeraNota()
          Endif   
          _aPedAgl  := {}       
          LimpArray()
      Else 
         _nRefaz     := 0
         _cNota      := ''
         _aPvlNfsAnt := aPvlNfs
         aPvlNfs     := {}
         For _nXGer := 1 To Len(_aPvlNfsAnt)
             AaDd(aPvlNfs,_aPvlNfsAnt[_nXGer])
             ++_nRefaz
             If (_nRefaz = GetMV('MV_NUMITEN')) .Or. (_nXGer = Len(_aPvlNfsAnt))
                If Empty(_cNota)
                   _cNota    := GeraNota()
                   _cNotaPri := _cNota
                Else
                   _cNota    := GeraNota()
                Endif   
                LimpArray()
                _nRefaz := 0
             Endif   
          Next
          _aPedAgl  := {}       
       Endif   
    Endif   
Next

If Len(aPedS) > 0 .And. _lVerAglut	
   _nItensNf := Posicione('SA1',1,xFilial('SA1')+_cCli,'A1_ITENSNF')
   _cItensAtu:= Str(GetMV('MV_NUMITEN'),2)
   If !Empty(_nItensNf)
      _cAliAnt := Alias()
      
      PutMV("MV_NUMITEN",Alltrim(Str(_nItensNf,2)))
                                                    
      DbSelectArea(_cAliAnt)
   Endif
   If Len(aPvlNfs) <= GetMV('MV_NUMITEN')
      _cNota := GeraNota()
      _aPedAgl  := {}   
      LimpArray()  
   Else 
      _nRefaz     := 0
      _cNota      := ''
      _aPvlNfsAnt := aPvlNfs
      _aPedAglAnt := _aPedAgl
      _aPedAgl    := {}               
      aPvlNfs     := {}
      For _nXGer := 1 To Len(_aPvlNfsAnt)
          AaDd(aPvlNfs,_aPvlNfsAnt[_nXGer])
          ++_nRefaz
          If (_nRefaz = GetMV('MV_NUMITEN')) .Or. (_nXGer = Len(_aPvlNfsAnt))
             If (_nXGer = Len(_aPvlNfsAnt))
                _aPedAgl := _aPedAglAnt
             Endif   
             If Empty(_cNota)
                _cNota    := GeraNota()
                _cNotaPri := _cNota
             Else
                _cNota    := GeraNota()
             Endif   
             LimpArray()
             _nRefaz := 0
          Endif   
      Next
   Endif   
   If !Empty(_nItensNf)
      _cAliAnt := Alias()
      PutMV("MV_PRICOMP",_cItensAtu)
                               
      DbSelectArea(_cAliAnt)
   Endif
Endif
                 
If Len(aPedS) > 0 .And. !Empty(_cNota)
   If sx1->(DbSeek("NFSIGW"+"01",.f.).and.reclock(alias(),.f.))                   
      sx1->x1_cnt01:= If(!Empty(_cNotaPri),_cNotaPri,_cNota)
      sx1->(msunlock())
   Endif   
   If sx1->(DbSeek("NFSIGW"+"02",.f.).and.reclock(alias(),.f.))                   
      sx1->x1_cnt01:= SF2->F2_DOC
      sx1->(msunlock())
   Endif
   If sx1->(DbSeek("NFSIGW"+"03",.f.).and.reclock(alias(),.f.))                   
      sx1->x1_cnt01:= cSerie
      sx1->(msunlock())
   Endif

   _cProgNf := GetMV('MV_PROGNF')                
   _cProgNf := &_cProgNf
                      
Endif   
          
If cArq <> ''
   DbSelectArea("TC9")
   DbCloseArea()
   FErase(cArq+OrdBagExt())
   FErase(_cIndex+ordbagext())
   _cIndex := ''
   cArq    := ''
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLimpArray   บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LimpArray()

aPvlNfs := {}
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraNota    บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraNota()
Local _nXGN

_cNotaG := ''
If Len( aPvlNfs ) > 0
	
	Pergunte(Padr("MT460A",Len(SX1->X1_GRUPO)) ,.F.) 
	_cNotaG := MaPvlNfs(aPvlNfs,cSerie,mv_par01 == 1,mv_par02==1,mv_par03==1,mv_par04==1,mv_par05==1,mv_par07,mv_par08,mv_par15 == 1,mv_par16==2)

    MsgBox(STR0010+_cNotaG,STR0011,"INFO") //"Numero da Nota: "###"Nota Fiscal"

    For _nXGN := 1 To Len(aPvlNfs)
        DbSelectArea('SC9')
	    DbSetOrder(1)
	    If DbSeek(xFilial('SC9')+aPvlNfs[_nXGN,1]+aPvlNfs[_nXGN,2]+aPvlNfs[_nXGN,3])
	       If Empty(SC9->C9_NFISCAL) .And. !Empty(_cNotaG)
	          RecLock('SC9',.F.)
   	          SC9->C9_BLCRED := '10'   
   	          SC9->C9_BLEST  := '10'   	          
   	          SC9->C9_NFISCAL:= _cNotaG
   	          SC9->C9_SERIENF:= cSerie
   	          MsUnLock()
	       Endif
	    Endif
    Next
	
	If Len(_aPedAgl) > 0
	   For _nXGN := 1 To Len(_aPedAgl) 
  	       DbSelectArea('SC9')
	       DbSetOrder(1)
	       If DbSeek(xFilial('SC9')+_aPedAgl[_nXGN,1]+_aPedAgl[_nXGN,2]+_aPedAgl[_nXGN,3])
	          _nRec := Recno()
	          If DbSeek(xFilial('SC9')+_aPedAgl[_nXGN,5]+_aPedAgl[_nXGN,6]+_aPedAgl[_nXGN,7])
	             _cNotGer := SC9->C9_NFISCAL
   	             _cSerGer := SC9->C9_SERIENF
      	         DbGoTo(_nRec)
   	             RecLock('SC9',.F.)
   	             SC9->C9_BLCRED := '10'   
   	             SC9->C9_BLEST  := '10'   	          
   	             SC9->C9_NFISCAL:= _cNotGer
   	             SC9->C9_SERIENF:= _cSerGer   	          
   	             MsUnLock()
   	             DbSelectArea('SC6')
   	             DbSetOrder(1)
   	             If DbSeek(xFilial('SC6')+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO)
   	                RecLock('SC6',.F.)
   	                SC6->C6_QTDENT += SC9->C9_QTDLIB
   	                SC6->C6_QTDEMP -= SC9->C9_QTDLIB   	                
   	                SC6->C6_NOTA   := _cNotGer
   	                SC6->C6_SERIE  := _cSerGer   	                
   	                SC6->C6_DATFAT := dDatabase
   	                MsUnLock()
    	            DbSelectArea('SC5')
   	                DbSetOrder(1)
   	                If DbSeek(xFilial('SC5')+SC9->C9_PEDIDO) .And. SC6->C6_QTDVEN = SC6->C6_QTDENT
   	                   RecLock('SC5',.F.)
   	                   SC5->C5_NOTA := _cNotGer
   	                   SC5->C5_SERIE:= _cSerGer   	                   
   	                   MsUnLock()
   	                Endif
   	             Endif
   	             DbSelectArea('SC6')
   	             DbSetOrder(1)
   	             If DbSeek(xFilial('SC6')+_aPedAgl[_nXGN,5]+_aPedAgl[_nXGN,6]+SC9->C9_PRODUTO)
   	                RecLock('SC6',.F.)
   	                SC6->C6_QTDENT -= SC9->C9_QTDLIB
                    SC6->C6_QTDEMP += SC9->C9_QTDLIB 
   	                MsUnLock()
   	             Endif
              Endif
	       Endif
	   Next    
	   _nVolumes := 0
	   For _nXGN := 1 To Len(_aPedAgl) 
  	       DbSelectArea('SC5')
	       DbSetOrder(1)
	       If DbSeek(xFilial('SC5')+_aPedAgl[_nXGN,1])
	          _nVolumes += SC5->C5_VOLUME1
	       Endif
	   Next	   
	   If _nVolumes > 0
	      DbSelectArea('SF2')
	      DbSetOrder(1)
	      If DbSeek(xFilial('SF2')+_cNotGer+_cSerGer)
	         RecLock('SF2',.F.)
	         SF2->F2_VOLUME1 := _nVolumes
	         MsUnlock()
	      Endif
	   Endif
	Endif
	If Type("oGeraNf") <> "U"
   	   //Close(oGeraNf)	
   	Endif   
Else
	MsgBox (STR0012,STR0013,"ALERT") //"Nao existe dados para ser gerado Nota Fiscal. Verifique liberacoes"###"Aten็ao"
    //Close(oGeraNf)	
EndIf
Return(_cNotaG)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMontaArray  บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MontaArray()

aPedS := {}
DbSelectArea('TC9')
DbGoTop()
_cCliente := ''
While !Eof()
   If TRIM(T9_OK) == _cMarca
      AaDd(aPedS,TC9->T9_PEDIDO)
      If Empty(_cCliente)
         _cCliente := TC9->T9_CLIENTE
      Else
         If _lVerAglut .And. _cCliente <> TC9->T9_CLIENTE
            MsgStop(STR0014+Chr(13)+; //'Na Aglutinacao Selecionar Somente um Cliente!'
                    STR0015+_cCliente+Chr(13)+; //'Primeiro Cliente Selecionado = '
                    STR0016+TC9->T9_CLIENTE) //'Segundo Cliente Selecionado = '
            DbGoTop()
            Return(.T.)
         Endif
      Endif   
      If AT(STR0017,TC9->T9_MENSA) > 0 .And. !_lVerAglut //'Aglutina'
            MsgStop(STR0018+Chr(13)+; //'Na Selecao Contem Pedidos para Aglutinar,'
                    STR0019) //'e a opcao de Aglutinacao nao esta selecionada abaixo!'
            DbGoTop()
            Return(.T.)
      EndIf
      If AT('(',TC9->T9_MENSA) > 0 
         If TC9->T9_QTDITEM <> Val(SubStr(TC9->T9_MENSA,AT('(',TC9->T9_MENSA)+1,(AT(')',TC9->T9_MENSA)-AT('(',TC9->T9_MENSA))-1))
            MsgStop(STR0020+Chr(13)+; //'Na Selecao Contem Pedidos para Faturamento Integral,'
                    STR0021+TC9->T9_PEDIDO) //'com Quantidade de Itens Faltantes! Pedido:'
            DbGoTop()
            Return(.T.)
         Endif   
      Endif
      If AT(STR0022,TC9->T9_MENSA) > 0  //'Sem Frete'
            MsgStop(STR0023+Chr(13)+; //'Na Selecao Contem Pedidos para Faturamento sem Frete,'
                    STR0024+Alltrim(GetMv('MV_SERIE2'))+' !') //'Utilize a tela inicial para Faturamento, utilizando a Serie '
            DbGoTop()
            Return(.T.)
      Endif
   Endif
   DbSkip()
End        
Close(oDlgPedidos)
If Len(aPedS) > 0
   ConfirmaProc()
EndIf
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVisualPed   บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VisualPed(_cPed,nTipo)
If Empty(_cPed)
   Return(.T.)
Endif
cAlias := "SC9"
DbSelectArea(cAlias)
DbSetOrder(1)
DbSeek(xFilial(cAlias)+_cPed)
aHeader := {}
DbSelectArea('SX2')
DbSeek(cAlias)
DbSelectArea('SX3')
DbSeek(cAlias)
nUsado := 0
While !EOF() .And. X3_ARQUIVO == cAlias
	If x3_usado != " " .And. cNivel >= X3_NIVEL .And. X3_BROWSE = 'S'  .And. X3_CONTEXT <> 'V'
        nUsado := nUsado + 1
		AADD(aHeader,{ TRIM(X3_TITULO), X3_CAMPO, X3_PICTURE,;
			X3_TAMANHO, X3_DECIMAL, X3_VALID,;
			X3_USADO, X3_TIPO, X3_ARQUIVO } )
	EndIf
	DbSkip()
EndDo
DbSelectArea(cAlias)
DbSeek(xFilial(cAlias)+_cPed)
nCnt := 0
While (cAlias)->(! Eof()) .And. (cAlias)->C9_FILIAL == xFilial(cAlias) .AND. (cAlias)->C9_PEDIDO == _cPed
      If nTipo = 1
         If SC9->C9_BLEST = '10' .OR. !Empty(SC9->C9_NFISCAL)
             DbSkip()
             Loop
         Endif
      Else    
         if !(empty(SC9->C9_BLEST+SC9->C9_NFISCAL).and.SC9->C9_BLCONF ='OK'.and.!empty(SC9->C9_BLPRE))
     	    dbSkip()
   	        Loop
   	     Endif      
   	  Endif   
      nCnt := nCnt+1
      DbSkip()
End  
If nCnt = 0
   MsgStop(STR0025) //'Pedido ja Faturado !!!'
   Return(.T.)
Endif
aCOLS := Array(nCnt,nUsado+1)
DbSelectArea( cAlias )
DbSeek(xFilial(cAlias)+_cPed)
nCnt := 0
While (cAlias)->(! Eof()) .And. (cAlias)->C9_FILIAL == xFilial(cAlias) .AND. (cAlias)->C9_PEDIDO == _cPed
      If nTipo =1
         If SC9->C9_BLEST = '10' .OR. !Empty(SC9->C9_NFISCAL)
            DbSkip()
            Loop
         Endif
	  Else    
         If !(Empty(SC9->C9_BLEST+SC9->C9_NFISCAL).and.SC9->C9_BLCONF ='OK'.and.!empty(SC9->C9_BLPRE))
            DbSkip()
            Loop
         Endif
      Endif   
      nCnt := nCnt+1
 	  nUsado:=0
      DbSelectArea('SX3')
	  DbSeek(cAlias)
      While !EOF() .And. X3_ARQUIVO == cAlias
	        If x3_usado != " " .And. cNivel >= X3_NIVEL .And. X3_BROWSE = 'S' .And. X3_CONTEXT <> 'V'
               nUsado := nUsado+1
               aCOLS[nCnt][nUsado] := &(cAlias+"->"+x3_campo)
	        EndIf
		    DbSkip()
	  End  
      aCOLS[nCnt][nUsado+1] := .f. //Flag de Delecao
	  dbSelectArea( cAlias )
	  Skip
End  
DbSelectArea( cAlias )
DbSeek(xFilial(cAlias)+_cPed)
@ 200,001 TO 400,540 DIALOG oDlgVisuPed TITLE STR0026+_cPed //"Pedido "
@ 006,005 TO 090,230 MULTILINE FREEZE 1 
@ 070,231 BUTTON "_Ok" SIZE 40,15 ACTION Close(oDlgVisuPed)
ACTIVATE DIALOG oDlgVisuPed CENTERED
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCria_TC9    บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static FUNCTION Cria_TC9()

aFields   := {}
AADD(aFields,{"T9_OK"     ,"C",02,0})
AADD(aFields,{"T9_SEQ"    ,"N",03,0})
AADD(aFields,{"T9_PEDIDO" ,"C",06,0})
AADD(aFields,{"T9_CLIENTE","C",06,0})
AADD(aFields,{"T9_NOMCLI" ,"C",40,0})
AADD(aFields,{"T9_VALOR"  ,"N",10,2})
AADD(aFields,{"T9_QTDITEM","N",03,0})
AADD(aFields,{"T9_MENSA"  ,"C",50,0})
//DbCloseArea()
cArq:=Criatrab(aFields,.T.)
DbUseArea(.t.,,cArq,"TC9")
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMonta_TC9   บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Monta_TC9()
Local _nX

For _nX := 1 To 2
    If _nX = 1
   	   cQueryCad := "SELECT COUNT(DISTINCT C9_PEDIDO) AS TOTAL FROM "+RetSqlName('SC9')+" C9  WHERE "
   	Else 
   	   cQueryCad := "SELECT DISTINCT C9_PEDIDO AS T9_PEDIDO, C9_CLIENTE AS T9_CLIENTE, A1_NOME AS T9_NOMCLI, SUM(C9_PRCVEN*C9_QTDLIB) AS T9_VALOR, " 
   	   cQueryCad += "(SELECT COUNT(DISTINCT C92.C9_PRODUTO) FROM "+RetSqlName('SC9')+" C92  WHERE "
   	   cQueryCad += "C92.D_E_L_E_T_ <> '*' AND "
   	   cQueryCad += "C92.C9_PEDIDO = C9.C9_PEDIDO AND "
   	   cQueryCad += "C92.C9_BLEST = ' ' AND "
   	   cQueryCad += "C92.C9_BLCRED = ' ' AND "
   	   cQueryCad += "C92.C9_BLCONF = 'OK' AND "
   	   cQueryCad += "C92.C9_NFISCAL = ' ' AND "   	   
   	   cQueryCad += "C92.C9_BLPRE <> ' ') AS T9_QTDITEM "
   	   cQueryCad += "FROM "+RetSqlName('SC9')+" C9 , "+RetSqlName('SA1')+" A1  WHERE "
   	Endif
	cQueryCad += "C9.D_E_L_E_T_ <> '*' AND "
    If _nX = 2	
  	   cQueryCad += "A1.D_E_L_E_T_ <> '*' AND "
	   cQueryCad += "A1.A1_FILIAL = '"+xFilial("SA1")+"' AND "
	   cQueryCad += "A1.A1_COD = C9.C9_CLIENTE AND "	
	   cQueryCad += "A1.A1_LOJA = C9.C9_LOJA AND "		
	Endif   
	cQueryCad += "C9.C9_FILIAL = '"+xFilial("SC9")+"' AND "
	cQueryCad += "C9.C9_BLEST = ' ' AND "
	cQueryCad += "C9.C9_BLCRED = ' ' AND "
	cQueryCad += "C9.C9_BLCONF = 'OK' AND "
	cQueryCad += "C9.C9_BLPRE <> ' ' AND "
	cQueryCad += "C9.C9_NFISCAL = ' ' "	
	If !Empty(MV_PAR01)
   	   cQueryCad += " AND C9.C9_VEND = '"+MV_PAR01+"' "
   	Endif              
	If !Empty(MV_PAR02)   	
   	   cQueryCad += " AND C9.C9_CLIENTE = '"+MV_PAR02+"' "
   	Endif   
    If _nX = 2
   	   cQueryCad += "GROUP BY C9.C9_PEDIDO, C9.C9_CLIENTE, A1.A1_NOME "
  	   cQueryCad += "ORDER BY C9.C9_PEDIDO, C9.C9_CLIENTE, A1.A1_NOME "
  	Endif   

	TCQUERY cQueryCad NEW ALIAS "CAD"
	If _nX = 1
	   _nCount := CAD->TOTAL
	   DbCloseArea()
	Endif
Next	

Dbselectarea("TC9")                  
DbGoTop()   
While !Eof()
   If TC9->T9_QTDITEM = 0
      RecLock('TC9',.F.)
      TC9->T9_QTDITEM := 0
      MsUnlock()
   Endif   
   DbSkip()
EndDo   
DbGoTop()   

Dbselectarea("CAD")                  

ProcRegua(_nCount)

_nSeq   := 0
_nTotal := 0
While CAD->(!EOF())
	IncProc()
	DbSelectArea('TC9')
	_lIncl := .T.
	If !Empty(_cIndex)
  	   If !DbSeek(CAD->T9_PEDIDO)
  	      RecLock("TC9",.T.)
   	   Else   
  	      _lIncl := .F.  	
  	      RecLock("TC9",.F.)
  	   Endif
  	Else      
       RecLock("TC9",.T.)  	
  	Endif   
    For _nX := 1 To Len(aFields)
        If !(aFields[_nX,1] $ 'T9_OK/T9_SEQ/T9_MENSA')
           If aFields[_nX,2] = 'C'
              _cX := 'TC9->'+aFields[_nX,1]+' := Alltrim(CAD->'+aFields[_nX,1]+')'
           Else
              _cX := 'TC9->'+aFields[_nX,1]+' := CAD->'+aFields[_nX,1]           
           Endif   
           _cX := &_cX           
        Endif   
    Next
    ++_nSeq
    If _lIncl
       TC9->T9_SEQ := _nSeq
    Endif   
    If TRIM(T9_OK) == _cMarca
       _nTotal += TC9->T9_VALOR
    Endif   
    DbSelectArea('SC5')
    DbSetOrder(1)
    If DbSeek(xFilial('SC5')+TC9->T9_PEDIDO)
       _cMensa := ''
       If SC5->C5_FATINT = 'S'
          DbSelectArea('SC6')
          DbSetOrder(1)
          DbSeek(xFilial('SC6')+TC9->T9_PEDIDO)
          _nContaIt := 0
 		  _aItePed  := {}
          While SC6->(! Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == TC9->T9_PEDIDO 
		     If AsCan(_aItePed,SC6->C6_PRODUTO) = 0
			    ++_nContaIt
			    AaDd(_aItePed,SC6->C6_PRODUTO)
             Endif
             DbSkip()
          EndDo
          _cMensa := STR0027+Str(_nContaIt,3)+STR0028 //'Fat.Integral ('###') Itens'
       Endif   
       If SC5->C5_AGLUTIN = 'S' .Or. Posicione('SA1',1,xFilial('SA1')+SC5->C5_CLIENTE+SC5->C5_LOJACLI,'A1_AGLUTIN') = 'S'
          _cMensa += STR0029 //' [Aglutina]'
       Endif
       TC9->T9_MENSA := _cMensa
    Endif
    If _lIncl .And. (Empty(TC9->T9_MENSA) .Or. (!Empty(TC9->T9_MENSA) .And. SC5->C5_FATINT = 'S' .And. TC9->T9_QTDITEM == _nContaIt .And. Len(_cMensa) == 24 ))
       TC9->T9_OK  := _cMarca
    Else                        
       TC9->T9_OK  := ThisMark()
    Endif   
    MsUnLock()   	   
	DbSelectArea('CAD')    
	CAD->(dBSkip())
End
Dbselectarea("CAD")                  
DbCloseArea()
Dbselectarea("TC9")                  
DbGoTop()   
If !Empty(_cIndex)
   While !Eof()
      If TC9->T9_QTDITEM = 0
         RecLock('TC9',.F.)
         DbDelete()
         MsUnlock()
      Endif   
      DbSkip()
   End  
   DbGoTop()   
EndIf   

If Empty(_cIndex)
   _cIndex:=Criatrab(Nil,.F.)
Else   
   FErase(_cIndex+ordbagext())
   _cIndex:=Criatrab(Nil,.F.)
Endif   
_cChave:="T9_PEDIDO"
Indregua("TC9",_cIndex,_cChave,,,STR0030) //"Ordenando registros selecionados..."
DbSetIndex(_cIndex+ordbagext())
SysRefresh()

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMulti       บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Multi()

Cria_TC9()
DbSelectArea('TC9')

If !Pergunte('RFTA01',.T.)
   Return(.T.)
Endif   

INCLUI       := .F.
aCampos      := {}
_cPesqPed    := Space(6)
_nTotal      := 0

AADD(aCampos,{'T9_OK','','@!','2','0'})
AADD(aCampos,{'T9_SEQ',STR0031,'999','3','0'}) //'Seq'
AADD(aCampos,{'T9_PEDIDO',STR0032,'@!','6','0'}) //'Pedidos'
AADD(aCampos,{'T9_CLIENTE',STR0033,'@!','6','0'}) //'Clientes'
AADD(aCampos,{'T9_NOMCLI',STR0034,'@!','40','0'}) //'Razao Social'
AADD(aCampos,{'T9_VALOR',STR0035,'@ER 999,999.99','10','2'}) //'Total'
AADD(aCampos,{'T9_QTDITEM',STR0036,'999','3','0'}) //'Itens Lib.'
AADD(aCampos,{'T9_MENSA',STR0037,'@!','2','0'}) //'Mensagem'

@ 100,005 TO 500,750 DIALOG oDlgPedidos TITLE STR0038 //"Pedidos"
@ 006,005 TO 190,325 BROWSE "TC9" MARK "T9_OK" FIELDS aCampos Object _oBrwPed
@ 006,330 BUTTON STR0039 SIZE 40,15 ACTION VisualPed(TC9->T9_PEDIDO,1) //"L_iberacoes"
@ 026,330 BUTTON STR0040 SIZE 40,15 ACTION VisualPed(TC9->T9_PEDIDO,2) //"_Liberados"
@ 046,330 BUTTON STR0041 SIZE 40,15 ACTION Processa({|| Monta_TC9() } ,STR0042) //"_Atualizar"###"Selecionando Informacoes dos Pedidos..."
@ 066,330 BUTTON STR0043 SIZE 40,15 ACTION MontaArray() //"_Confirmar"
@ 183,330 BUTTON STR0044 SIZE 40,15 ACTION Close(oDlgPedidos) //"_Sair"
                          
Processa({|| Monta_TC9() } ,STR0042) //"Selecionando Informacoes dos Pedidos..."

_oBrwPed:bMark := {|| Marcar()}

@ 106,330 SAY STR0045 //"Pesquisa Pedido"
@ 116,335 GET _cPesqPed    Valid Pesquisa()
@ 193,005 CHECKBOX STR0046 VAR _lVerAglut //"Aglutinacao de Pedidos de um Cliente"
@ 136,330 SAY STR0047 //"Total Pedidos: "
@ 146,330 SAY Str(_nTotal,12,2)

ACTIVATE DIALOG oDlgPedidos CENTERED

If cArq <> ''
   DbSelectArea("TC9")
   DbCloseArea()
   FErase(cArq+OrdBagExt())
   FErase(_cIndex+ordbagext())
   _cIndex := ''
   cArq    := ''
EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMarcar      บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   

Static Function Marcar()
DbSelectArea('TC9')
RecLock('TC9',.F.)
If Empty(TC9->T9_OK)
   TC9->T9_OK := _cMarca
EndIf   
MsUnlock()
SysRefresh()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPesquisa    บAutor  ณMicrosiga           บ Data ณ  08/18/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                              บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP8                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 

Static FUNCTION Pesquisa()
If !Empty(_cPesqPed)
   DbSelectArea('SC5')
   DbSetOrder(1)
   If !DbSeek(xFilial('SC5')+_cPesqPed)
      MsgStop(STR0050) //'Pedido nao Encontrado !!!'
      Return(.F.)
   Endif   
   VisualPed(_cPesqPed,1)
Endif
Return(.T.)