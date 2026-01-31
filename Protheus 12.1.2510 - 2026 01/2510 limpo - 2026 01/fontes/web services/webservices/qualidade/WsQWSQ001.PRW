#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWSQWSQ001 บAutor  ณTelso Carneiro      บ Data ณ  06/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function QDODocuments() // (Gambiarra) Somente para poder gerar patch
Return
WSSERVICE QDODocuments          DESCRIPTION "Servico de consulta a Documentos Vigentes" 
	WSDATA UserCode               AS String
	WSDATA aHeader                AS Array Of AHEADQDHVIEW
	WSDATA aCols                  AS Array Of ACOLSQDHVIEW
	WSDATA aQPath                 As Array Of AQDOMVPATHVIEW
	WSDATA NomDoc				  AS String 
	WSDATA PatchDoc				  AS String
	WSDATA OffSet				  AS Integer
	WSDATA aBuffer			  	  As Array Of ABUFFERVIEW
	WSDATA FilCodRv				  AS String              
	WSDATA aFilehtm				  AS Array Of AFILEHTMQVIEW
	WSMETHOD GetaHeadDoc        DESCRIPTION "Metodo que descreve as estruturas de cabecalho servico"
	WSMETHOD GetDocument     	DESCRIPTION "Metodo que descreve os documentos ativos do sistema pela pendencia de leitura do usuario logado"
	WSMETHOD GetQDOPaths    	DESCRIPTION "Metodo que descreve os paths do sistema"
	WSMETHOD GetQDOFiles		DESCRIPTION "Metodo que recupera os arquivos dos documentos ativos do sistema"
	WSMETHOD GetQDOlsHtm		DESCRIPTION "Metodo que recupera os arquivos de imagens dos documentos html ativos do sistema e baixa a pendencia de leitura do usuario logado"
	WSMETHOD GetQDOBaixa		DESCRIPTION "Metodo que Baixa a pendencia de leitura do usuario logado"
ENDWSSERVICE

//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGetHeadeDocณ
//ภฤฤฤฤฤฤฤฤฤฤฤู
WSMETHOD GetaHeadDoc WSRECEIVE UserCode WSSEND aHeader WSSERVICE QDODocuments
Local aArea    := GetArea()
Local lRetorno := .T.
Local nX       := 0    
Local lQDHComp := ""  
Local cCampQDH := ""

If PrtChkUser(::UserCode,"QDODocuments","GetHeadeDoc")
	DbSelectArea("SX2")
	DbSetOrder(1)
	SX2->(DBSeek("QDH")) 
	lQDHComp:= SX2->X2_MODO=="C"
	cCampQDH:=IF(lQDHComp,"","QDH_FILIAL,")+"QDH_CODTP,QDH_DOCTO,QDH_RV,QDH_TITULO" 

    DbSelectArea("SX3")
    SX3->(DbSetOrder(1))
    SX3->(DBSEEK("QDH"))
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO=="QDH" 
		IF ALLTRIM(SX3->X3_CAMPO) $ cCampQDH
			aadd(::aHeader,WsClassNew("AHEADQDHVIEW"))
			nX++
			::aHeader[nX]:X3_CAMPO   	:= SX3->X3_CAMPO
			::aHeader[nX]:X3_PICTURE 	:= SX3->X3_PICTURE
			::aHeader[nX]:X3_TITULO 	:= SX3->X3_TITULO
		Endif
		SX3->(DBSkip())
	Enddo
	

Else
	lRetorno := .F.
EndIf
RestArea(aArea)
Return(lRetorno)            


       

//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGetDocumentณ
//ภฤฤฤฤฤฤฤฤฤฤฤู
WSMETHOD GetDocument WSRECEIVE UserCode WSSEND aCols WSSERVICE QDODocuments
Local aArea    := GetArea()
Local lRetorno := .T.
Local nX       := 0   
Local aUsrMat  := QUsrCfg( ::UserCode )
Local lApelido := aUsrMat[1] 
Local cMatFil  := aUsrMat[2]
Local cMatCod  := aUsrMat[3]
#IFDEF TOP
	Local cQuery   := ""
#ELSE
	Local cFiltro  := ""
#ENDIF

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se lApelido( indica se o apelido do usuario e igual ao do configurador ) ณ
//ณ permite utilizar ou nao a rotina                                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If PrtChkUser(::UserCode,"QDODocuments","GetDocument") .and. lApelido

	#IFDEF TOP
	
		If TcSrvType() != "AS/400"
			cQuery := "SELECT QDH.QDH_FILIAL,QDH.QDH_CODTP,QDH.QDH_DOCTO,QDH.QDH_RV,QDH.QDH_TITULO,QD1.QD1_PENDEN,"
			cQuery += "QDH.QDH_DTOIE,QDH.QDH_NOMDOC " 
			cQuery += " FROM " + RetSqlName("QD1")+" QD1, "
			cQuery += RetSqlName("QDH") + " QDH "
			cQuery += "WHERE "   
			cQuery += "QD1.QD1_FILMAT = '"  +cMatFil+"' "
			cQuery += "AND QD1.QD1_MAT = '"     +cMatCod+"' "
			cQuery += "AND QD1.QD1_TPPEND = 'L  ' AND QD1.QD1_SIT <> 'I' "
			cQuery += "AND ( QD1.QD1_TPDIST = '1' OR QD1.QD1_TPDIST = '3' ) "
			cQuery += "AND QD1.D_E_L_E_T_ <> '*' " 
			cQuery += "AND QDH.QDH_OBSOL  <> 'S' " 
			cQuery += "AND QDH.QDH_CANCEL <> 'S' "
			cQuery += "AND QDH.QDH_STATUS = 'L  ' "
			cQuery += "AND QDH.QDH_FILIAL = QD1.QD1_FILIAL "
			cQuery += "AND QDH.QDH_DOCTO = QD1.QD1_DOCTO "
			cQuery += "AND QDH.QDH_RV = QD1.QD1_RV "
			cQuery += "AND QDH.D_E_L_E_T_ <> '*' "
			cQuery += " ORDER BY " + SqlOrder("QDH_FILIAL+QD1_PENDEN+QDH_CODTP+QDH_DOCTO+QDH_RV")
					
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QDH_TRB', .F., .T.)
	
			DbSelectArea("QDH_TRB")
			DbGotop()
			While ("QDH_TRB")->(!Eof())
			
				aadd(::aCols,WsClassNew("ACOLSQDHVIEW"))
				nX++
				::aCols[nX]:FILIALDOC   := ("QDH_TRB")->QDH_FILIAL
				::aCols[nX]:TIPODOC     := ("QDH_TRB")->QDH_CODTP
				::aCols[nX]:CODIGODOC   := ("QDH_TRB")->QDH_DOCTO
				::aCols[nX]:RVDOC       := ("QDH_TRB")->QDH_RV
				::aCols[nX]:TITULODOC   := ("QDH_TRB")->QDH_TITULO
				::aCols[nX]:PENDUSR     := ("QDH_TRB")->QD1_PENDEN				
				::aCols[nX]:DTOIE       := ("QDH_TRB")->QDH_DTOIE
				::aCols[nX]:NOMDOC      := ("QDH_TRB")->QDH_NOMDOC
				::aCols[nX]:DESCTIPO    := POSICIONE("QD2",1,("QDH_TRB")->QDH_FILIAL+("QDH_TRB")->QDH_CODTP,"QD2_DESCTP")
				
				("QDH_TRB")->(DbSkip())
			EndDo
			("QDH_TRB")->(dbCloseArea())
		EndIf
	#ELSE
		DbSelectArea("QDH")
		DbSetOrder(1)
		cFiltro:= 'QDH->QDH_OBSOL  <> "S" .And. QDH->QDH_CANCEL <> "S" .And. QDH->QDH_STATUS == "L  "'
		DBSetFilter({|| &(cFiltro)},cFiltro)
	
		DbSelectArea("QD1")
		DbSetOrder(1)
		cFiltro:= 'QD1->QD1_TPPEND == "L  " .And. QD1->QD1_SIT <> "I" .And.'                          
		cFiltro+= '( QD1->QD1_TPDIST == "1" .OR. QD1->QD1_TPDIST == "3" ) .And.'
		cFiltro+= 'QD1->QD1_FILMAT == "'+cMatFil+'" .And. '
		cFiltro+= 'QD1->QD1_MAT == "'+cMatCod+'"'
		DBSetFilter({|| &(cFiltro)},cFiltro)
		dbGoTop()
			
		While QD1->(!Eof())
			If QDH->(DBSeek(QD1->QD1_FILIAL+QD1->QD1_DOCTO+QD1->QD1_RV))
				aadd(::aCols,WsClassNew("ACOLSQDHVIEW"))
				nX++
				::aCols[nX]:FILIALDOC   := QDH->QDH_FILIAL
				::aCols[nX]:TIPODOC     := QDH->QDH_CODTP
				::aCols[nX]:CODIGODOC   := QDH->QDH_DOCTO
				::aCols[nX]:RVDOC       := QDH->QDH_RV
				::aCols[nX]:TITULODOC   := QDH->QDH_TITULO
				::aCols[nX]:PENDUSR     := QD1->QD1_PENDEN				
				::aCols[nX]:DTOIE       := QDH->QDH_DTOIE
				::aCols[nX]:NOMDOC      := QDH->QDH_NOMDOC
				::aCols[nX]:DESCTIPO    := POSICIONE("QD2",1,QDH->QDH_FILIAL+QDH->QDH_CODTP,"QD2_DESCTP")
				QDH->(DbSkip())
			EndIf
			QD1->(DbSkip())
		EndDo
		DbSelectArea("QDH")
		DbClearFilter()
		DbSelectArea("QD1")			
	#ENDIF
	
Else
	lRetorno := .F.
EndIf
RestArea(aArea)
Return(lRetorno)            

//ฺฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGetQDOPathsณ
//ภฤฤฤฤฤฤฤฤฤฤฤู
WSMETHOD GetQDOPaths WSRECEIVE NULLPARAM WSSEND aQPath WSSERVICE QDODocuments
Local aArea    := GetArea()
Local lRetorno := .T.
Local nX       := 0
Local aWQPath  := {}
Local cQPath    := QA_TRABAR(Alltrim( GetMV( "MV_QPATHW"  )))
Local cQPathD   := QA_TRABAR(Alltrim( GetMV( "MV_QPATHWD" )))
Local cQPathHtm := QA_TRABAR(Alltrim( GetMV( "MV_QPATHWH" )))
Local cQPathTrm := Alltrim( GetMV( "MV_QPATHWT" ))
Local cTextoD   := Alltrim( GetMV( "MV_QDDOTPD" ))
Local cPathView := Alltrim( GetMv( "MV_QDPVIEW" ))
Local cUsaView  := AllTrim( GetMv( "MV_QDVIEW"  ))
Local cUsaHTML	:= AllTrim( GetMv( "MV_QDHTML"  ))
Local cQPathDir
Local cBarRmt	:=IIF(GetRemoteType() == 2	,"/","\")   //Checa se o Remote e Linux
Local cBarSrv	:=IIF(ISSRVUNIX()			,"/","\")   //Checa se o Server e Linux

cQPathDir:= "protheus_tmp"+cBarRmt

If UPPER(cQPathTrm) == "GETTEMPPATH()"
	cQPathTrm := "C:\TEMP"
	
	If Right( cQPathTrm, 1 ) # cBarRmt
		cQPathTrm  += cBarRmt
	Endif
	
	cQPathTrm := cQPathTrm+cQPathDir
Else
	If Right( cQPathTrm, 1 ) # cBarRmt
		cQPathTrm  += cBarRmt
	Endif
Endif

If Right( cQPath,  1 ) # cBarSrv
	cQPath  += cBarSrv
Endif
If Right( cQPathD, 1 ) # cBarSrv
	cQPathD += cBarSrv
Endif
If Right( cQPathHtm, 1 ) # cBarSrv
	cQPathHtm  += cBarSrv
Endif
If cUsaView == "S"
	If Right( cPathView, 1 ) # cBarRmt
		cPathView  += cBarRmt
	Endif
Endif

aWQPath := {cQPath,cQPathD,cQPathTrm,cTextoD,cQPathHtm,cPathView,cUsaView,cQPathDir,cUsaHTML}

::aQPath:={}
aadd(::aQPath,WsClassNew("AQDOMVPATHVIEW"))
nX++
::aQPath[nX]:QPATH     	:= aWQPath[1]
::aQPath[nX]:QPATHD    	:= aWQPath[2]
::aQPath[nX]:QPATHTRM  	:= aWQPath[3]
::aQPath[nX]:TEXTOD    	:= aWQPath[4]
::aQPath[nX]:QPATHHTM  	:= aWQPath[5]
::aQPath[nX]:PATHVIEW	:= aWQPath[6]
::aQPath[nX]:USAVIEW   	:= aWQPath[7]
::aQPath[nX]:QPATHDIR  	:= aWQPath[8]
::aQPath[nX]:USAHTML	:= aWQPath[9]

IF Len(::aQPath)==0
	lRetorno := .F.
EndIf
RestArea(aArea)
Return(lRetorno)
 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGetQDOFiles	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
WSMETHOD GetQDOFiles WSRECEIVE NomDoc,PatchDoc,OffSet WSSEND aBuffer WSSERVICE QDODocuments
Local aArea     	:= GetArea()
Local lRetorno  	:= .T.
Local cNomDoc 		:= ::NomDoc
Local cQPath  		:= ::PatchDoc
Local cBuffer		:= space(102400)
Local hArq
Local cFile			:= ""
Local nOffSet 		:= ::OffSet 
Local nX			:= 0
Local nI			:= 0

cFile:=cQPath+cNomDoc

If file(cFile)
	::aBuffer:={}
	hArq := FOpen(cFile)
	FSeek(hArq, nOffSet, 1)
	For nI:=1 To 5 
		cBuffer:= space(102400)		
		IF FRead(hArq, @cBuffer, 102400) > 0		 
			aadd(::aBuffer,WsClassNew("ABUFFERVIEW"))
			nX++
			::aBuffer[nX]:BUFFER   := cBuffer
		Endif
	Next		    
	FClose(hArq)						    
Else
	lRetorno := .F.
EndIf

RestArea(aArea)
Return(lRetorno)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGetQDOlsHtm ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
WSMETHOD GetQDOlsHtm WSRECEIVE NomDoc,PatchDoc WSSEND aFilehtm WSSERVICE QDODocuments
Local aArea     	:= GetArea()
Local lRetorno  	:= .T.
Local nX        	:= 0   
Local cNomDoc 		:= ::NomDoc
Local cQPath  		:= ::PatchDoc
Local cBuffer		:= ""
Local hArq
Local nTam
Local cFile			:= ""
Local cExt			:= ""
Local nI			:= 0 
Local nT			:= 0
Local aDiretorio	:= {}
Local nPosDir		:= 0
Local aData			:= {}

cFile:=cQPath+cNomDoc

If file(cFile)     
	aDiretorio:= DIRECTORY(cQPath+"\*.","D")
	If Len(aDiretorio) > 0
		nPosDir:= ASCAN(aDiretorio,{|X| Substr(cNomDoc,1,8)+"_" $ X[1] })
		If nPosDir > 0
			aadd(::aFilehtm,WsClassNew("AFILEHTMQVIEW"))
			nX++
			::aFilehtm[nX]:FILEHTM := aDiretorio[nPosDir,1]			
			aData  := DIRECTORY(cQPath+aDiretorio[nPosDir,1]+"\*.*")
			For nT:= 1 to Len(aData)
				If File(cQPath+aDiretorio[nPosDir,1]+"\"+AllTrim(aData[nT,1]))									
					aadd(::aFilehtm,WsClassNew("AFILEHTMQVIEW"))
					nX++
					::aFilehtm[nX]:FILEHTM := AllTrim(aData[nT,1])																
				Endif	
			Next        			
		Endif
	Endif
Else
	lRetorno := .F.
EndIf
RestArea(aArea)
Return(lRetorno)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGetQDOBaixa	 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
WSMETHOD GetQDOBaixa WSRECEIVE UserCode,FilCodRv WSSEND aBuffer WSSERVICE QDODocuments
Local aArea     	:= GetArea()
Local lRetorno  	:= .T.
Local cCodDoc		:= ::FilCodRv
Local aUsrMat  		:= QUsrCfg( ::UserCode )
Local cMatFil  		:= aUsrMat[2]
Local cMatCod  		:= aUsrMat[3]            
Local cMatDep		:= aUsrMat[4]            

DbSelectArea("QD1")
QD1->(DbSetOrder(1))
If QD1->(DbSeek( cCodDoc+ cMatDep + cMatFil + cMatCod ))
	While QD1->(!Eof()) .And. cCodDoc + cMatDep + cMatFil + cMatCod == QD1->QD1_FILIAL + QD1->QD1_DOCTO + QD1->QD1_RV + QD1->QD1_DEPTO + QD1->QD1_FILMAT + QD1->QD1_MAT
		If QD1->QD1_PENDEN == "P" .And. QD1->QD1_TPPEND == "L  "
			RecLock("QD1",.F.)
			QD1->QD1_DTBAIX := dDataBase
			QD1->QD1_PENDEN := "B"
			QD1->QD1_HRBAIX := SubStr( Time(), 1, 5 )
			QD1->QD1_LEUDOC := "S"
			QD1->QD1_FMATBX := cMatFil
			QD1->QD1_MATBX  := cMatCod
			QD1->QD1_DEPBX  := cMatDep
			QD1->QD1_DISTNE := "N"
			MsUnlock()
			FKCOMMIT()
		EndIf
		QD1->(DbSkip())
	Enddo
Else
	lRetorno:=.F.	
EndIf

RestArea(aArea)
Return(lRetorno)


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณESTRUTURAS DO WEBSERVICES ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
WSSTRUCT AHEADQDHVIEW
	WSDATA   X3_CAMPO                 AS string OPTIONAL
	WSDATA   X3_PICTURE               AS string OPTIONAL
	WSDATA   X3_TITULO                AS string OPTIONAL
ENDWSSTRUCT

WSSTRUCT ACOLSQDHVIEW
	WSDATA   FILIALDOC                AS string OPTIONAL
	WSDATA   TIPODOC                  AS string OPTIONAL
	WSDATA   CODIGODOC                AS string OPTIONAL
	WSDATA   RVDOC                    AS string OPTIONAL
	WSDATA   TITULODOC                AS string OPTIONAL
	WSDATA   PENDUSR                  AS string OPTIONAL
	WSDATA   DTOIE                    AS string OPTIONAL
	WSDATA   NOMDOC                   AS string OPTIONAL
	WSDATA   DESCTIPO				  AS string OPTIONAL
ENDWSSTRUCT

WSSTRUCT AQDOMVPATHVIEW
	WSDATA   PATHVIEW                 AS string OPTIONAL
	WSDATA   QPATH                    AS string OPTIONAL
	WSDATA   QPATHD                   AS string OPTIONAL
	WSDATA   QPATHDIR                 AS string OPTIONAL
	WSDATA   QPATHHTM                 AS string OPTIONAL
	WSDATA   QPATHTRM                 AS string OPTIONAL
	WSDATA   TEXTOD                   AS string OPTIONAL
	WSDATA   USAVIEW                  AS string OPTIONAL
	WSDATA   USAHTML				  AS string OPTIONAL
ENDWSSTRUCT


WSSTRUCT ABUFFERVIEW
	WSDATA BUFFER					 AS Base64Binary OPTIONAL
ENDWSSTRUCT

WSSTRUCT AFILEHTMQVIEW
	WSDATA FILEHTM					     AS string OPTIONAL
ENDWSSTRUCT