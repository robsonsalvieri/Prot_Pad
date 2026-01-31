#INCLUDE "FDARM002.ch"
/*********************************************************************************/
/* Funcao: Estorno de Mercadorias                                                */
/* Exclui uma nota gerada indevidadmente para Devolucao                          */
/*********************************************************************************/
Function FDARM002(oBrw,aItems)
Local cChaveF1:=""
Local nQtdel  :=0

if MsgYesOrNo(STR0001  , STR0002 ) //"Confirma o estorno destes itens ?"###"Estorna Nota"
   ExcluiD1(oBrw,aItems,@cChaveF1,@nQtdel)
   // Agora Esclui o cabecalho da Nota se for necessrio
   F1_Exclui(cChaveF1,nQtdel)
   MsgStop( STR0003 )  //"Estorno realizado"
else 
   Return 
endif

Return 

/*********************************************************************************/
/* Funcao: Exclui itens do SD1                                                   */
/*********************************************************************************/
Function ExcluiD1(oBrw,aItems,cChaveF1,nQtdel)
Local nI         :=0
Local nQtdEstorno:=0 
Local cSerie     := GetMV("MV_FDASERI", "RUA" )   
Local cChaveD1   := ""
Local cItemOri   := ""

dbSelectArea("HD1")     
dbSetOrder(2)      
for nI:=1 to Len(aItems) 
    // se o item esta marcado para deletar 
    If aItems[nI,1]==.t.          
      
        cItemOri := Substr( aItems[nI,3],1,4 )     

        cChaveD1 := Alltrim( aItems[nI,9] + aItems[nI,2] + cItemOri+"  " + aItems[nI,4] )
        cChaveF1 := aItems[nI,9] + cSerie   
        
		if HD1->( dbSeek( cChaveD1 ) )   
	       nQtdEstorno:= HD1->D1_QUANT 
	       HD1->( dbDelete() ) 
		   HD1->( dbCommit() )	
		   //Devolve a quantidade estornada ao HB6
		   dbSelectArea( "HB6" ) 
		   HB6->( dbGoto(aItems[nI,10]) ) // Usa o Recno do registro para fazer atualizacao 
	       //HB6->B2_QTD    := HB6->B2_QTD + nQtdEstorno
           HB6->B6_STATUS := " "  // Marca " " para devolucao                          
	       HB6->( dbCommit() )	
	       nQtdel := nQtdel + 1 
 	       aItems[nI,8] := " "    
           aItems[nI,9] := " "
           // Atualiza Browse 
           SetArray(oBrw,aItems)
        else
  	       Alert( STR0004 ) //"Itens nao encontrados para estornar "
		endif
	endif
Next

Return 

/*********************************************************************************/
/* Funcao: Exclui nota fiscal                                                    */
/*********************************************************************************/
Function F1_Exclui(cChaveF1,nQtdel)
dbSelectArea("HF1")
HF1->( dbSetOrder(1) )

If HF1->( dbSeek( cChaveF1 ) )
   if  HF1->F1_QTDITE == nQtdel
       HF1->( dbDelete() )
       HF1->( dbCommit() )
   endif
else                 
   Alert( STR0005 )  //"Nota nao encontrada para estornar !"
endif

Return 
