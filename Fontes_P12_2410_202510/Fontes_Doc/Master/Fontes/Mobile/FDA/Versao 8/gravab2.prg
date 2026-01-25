#include "eadvpl.ch"
FUNCTION gravab2()
MSGSTATUS("Aguarde ..." )

USE HB2990 ALIAS HB2 SHARED NEW VIA "LOCAL"
while HB2->(!eof())

      HB2->B2_ORI:=100
      HB2->B2_QTD:=100
      hb2->( dbCommit()) 


      dbSkip()
enddo

ClearStatus()
RETURN 
