#Include "Protheus.Ch"
              
Template Function PCLCarAbast()       


Local oOk   	:= LoadBitmap( GetResources(), "LBOK" )
Local oNo   	:= LoadBitmap( GetResources(), "LBNO" )  
Local cQuery 	:= ""

aAreSav := GetArea()
aDadosBMB := {}


	cQuery := " SELECT LEG_CODBIA,"                                                           
	cQuery += " LEG_PREPLI, "
	cQuery += "	LEG_LITABA, "	                                                        
	cQuery += "	LEG_TOTAPA, "    
	cQuery += "	LEG_ENCERR, " 
	cQuery += "	LEG_CODIGO,  "
	cQuery += "	LEG_HORACO,  "
	cQuery += "	LEG_DATACO,  "
	cQuery += "	LEF_DESCRI  "
	 
	cQuery +=    " FROM "+ RetSQLName( "LEG" ) + " LEG "   
	cQuery +=    " INNER JOIN " + RetSQLName( "LEF" ) + " LEF " 
   	cQuery +=    " ON LEF.LEF_BICO = LEG.LEG_CODBIA "                                              
     
	cQuery +=    " WHERE LEG.LEG_NUMORC = '' "    
	cQuery +=    " AND LEG.D_E_L_E_T_ <> '*' "    
	                                     
	cQuery +=    " ORDER BY LEG.LEG_CODIGO " 

	cQuery := ChangeQuery(cQuery) 
	                                                                              
If select("QRY")<>0
	QRY->(dbclosearea())
EndIf
                                        
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QRY",.F.,.T.)                                   
	

While !Eof() 
			aAdd(aDadosBMB,{.F.,ALLTRIM(QRY->LEG_CODBIA),ALLTRIM(QRY->LEG_PREPLI),ALLTRIM(QRY->LEG_LITABA),Transform(val(QRY->LEG_TOTAPA), "@E 999,999,999.99"),ALLTRIM(QRY->LEG_ENCERR),ALLTRIM(QRY->LEG_CODIGO), .T.,STOD(QRY->LEG_DATACO), QRY->LEG_HORACO, ALLTRIM(QRY->LEF_DESCRI)})
	DbSkip()                                    	
Enddo
                                                                                                                        
                                                                                                                       
IF len(aDadosBMB) == 0
   	aAdd(aDadosBMB,{.F., "", "Não existem abastecimento pendentes!", "", "", "", "", .F., "", "", ""}) 
EndIF	

oLbx1:SetArray(aDadosBMB)                                                               
oLbx1:bLine := { || {iif(aDadosBMB[oLbx1:nAt,1],oOk,oNo) , aDadosBMB[oLbx1:nAt,2],;                        
				aDadosBMB[oLbx1:nAt,11], aDadosBMB[oLbx1:nAt,3],aDadosBMB[oLbx1:nAt,4],;
				aDadosBMB[oLbx1:nAt,5], aDadosBMB[oLbx1:nAt,9], aDadosBMB[oLbx1:nAt,10]  } }
oLbx1:Refresh()

RestArea(aAreSav)
                                                                           
Return
