#Include 'Protheus.ch'  
#INCLUDE "WMSA370.CH"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ WMSA371 | Autor ³ Alex Egydio              ³Data³29.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atribui o SEPARADOR e endereco de servico ao mapa CONSOLIDADO³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function WmsA371()
If !Pergunte('WMA370',.T.)
   Return NIL
EndIf
WmsA370('1')
Return NIL
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ WMSA372 | Autor ³ Alex Egydio              ³Data³29.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atribui o CONFERENTE e endereco de servico ao mapa de separacao de CAIXA FECHADA / FRACIONADO³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function WmsA372()
If !Pergunte('WMA372',.T.)
   Return NIL
EndIf
WmsA370('2')
Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ WMSA370 | Autor ³ Alex Egydio              ³Data³29.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function WmsA370(cAcao)
	If SuperGetMV("MV_WMSNEW", .F., .F.)
		MsgRun(STR0001,,{|| WmsA371Prc(cAcao) }) //wmsa371prc usa D12 // Aguarde...
	Else
		MsgRun(STR0001,,{|| WmsA370Prc(cAcao) }) //wmsa371prc usa SDB // Aguarde...
	EndIf
Return NIL
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³WMSA370Prc| Autor ³ Alex Egydio             ³Data³29.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atribui o operador e endereco de servico aos mapas         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function WmsA370Prc(cAcao)
Local aAreaSDB := SDB->(GetArea())
Local cAliasNew := 'SDB'
Local cQuery   := ''
Local cVazio   := Space(Len(SDB->DB_RECHUM))
Local cSemMpCon := Space(Len(SDB->DB_MAPCON))
Local cSemMpSep := Space(Len(SDB->DB_MAPSEP))

Local cMapCon  := ''
Local cCodSep  := ''
Local cEndServ := ''
Local cCodConf := ''
Local cMapSep  := ''
// Permite incluir e alterar, se o codigo do usuario estiver contido em MV_WMSACES
// caso contrario somente inclui
Local lInclui  := !(__cUserID$AllTrim(SuperGetMV('MV_WMSACES',.F.,' ')))
Local lRet     := .F.

   If cAcao=='1'
      cMapCon := mv_par01
   Else
      cMapSep := mv_par01
   EndIf
   cCodSep  := mv_par02
   cEndServ := mv_par03
   cCodConf := mv_par04

   cAliasNew:= GetNextAlias()
   cQuery := "SELECT SDB.DB_MAPCON,SDB.DB_MAPSEP,SDB.DB_RECHUM,SDB.R_E_C_N_O_ RECSDB "
   cQuery +=  " FROM "+RetSqlName('SDB')+" SDB"
   cQuery += " WHERE SDB.DB_FILIAL = '"+xFilial("SDB")+"'"
   cQuery +=   " AND SDB.DB_ESTORNO = ' '"
   cQuery +=   " AND SDB.DB_ATUEST = 'N'"
   cQuery +=   " AND SDB.DB_TM > '500'"

   If cAcao=='1'
      If lInclui
         cQuery += " AND SDB.DB_RECHUM = '"+cVazio+"'"
      EndIf
      cQuery += " AND SDB.DB_MAPCON <> '"+cSemMpCon+"'"
      cQuery += " AND SDB.DB_MAPCON = '"+cMapCon+"'"
   Else
      If lInclui
         cQuery += " AND SDB.DB_RECHUM = '"+cVazio+"'"
      EndIf
      cQuery += " AND SDB.DB_MAPSEP <> '"+cSemMpSep+"'"
      cQuery += " AND SDB.DB_MAPSEP = '"+cMapSep+"'"
   EndIf

   cQuery += " AND SDB.D_E_L_E_T_ = ' '"
   cQuery += " ORDER BY "+SqlOrder(SDB->(IndexKey(IndexOrd())))
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
   // Atribui o operador e o endereco de servico ao mapa consolidado
   While (cAliasNew)->(!Eof())
      SDB->(MsGoTo((cAliasNew)->RECSDB))
      RecLock('SDB',.F.)

      SDB->DB_RECHUM := cCodSep
      SDB->DB_ENDSERV:= cEndServ
      SDB->DB_RECCON := cCodConf
      SDB->DB_DATA   := dDataBase
      SDB->DB_HRINI  := Time()
      MsUnLock()
      lRet := .T.
      (cAliasNew)->(DbSkip())
   EndDo
   DbSelectArea(cAliasNew)
   DbCloseArea()
   RestArea(aAreaSDB)
   If !lRet
      If lInclui
         If cAcao=='1'
            Aviso('WMSA37001',STR0002,{'OK'}) // Mapa consolidado nao encontrado ou o operador ja foi atribuido por outro usuario!
         Else
            Aviso('WMSA37001',STR0003,{'OK'}) // Mapa de separacao nao encontrado ou o operador ja foi atribuido por outro usuario!
         EndIf
      Else
         If cAcao=='1'
            Aviso('WMSA37002',STR0004,{'OK'}) // Mapa consolidado nao encontrado!
         Else
            Aviso('WMSA37002',STR0005,{'OK'}) // Mapa de separacao nao encontrado!
         EndIf
      EndIf
   EndIf
Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³WMSA370Prc| Autor ³ Alex Egydio             ³Data³29.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atribui o operador e endereco de servico aos mapas         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function WmsA371Prc(cAcao)
Local aAreaD12 := D12->(GetArea())
Local cAliasNew := 'D12'
Local cQuery   := ''
Local cVazio    := Space(Len(D12->D12_RECHUM))
Local cSemMpCon := Space(Len(D12->D12_MAPCON))
Local cSemMpSep := Space(Len(D12->D12_MAPSEP))

Local cMapCon  := ''
Local cCodSep  := ''
Local cEndServ := ''
Local cCodConf := ''
Local cMapSep  := ''
// Permite incluir e alterar, se o codigo do usuario estiver contido em MV_WMSACES
// caso contrario somente inclui
Local lInclui  := !(__cUserID$AllTrim(SuperGetMV('MV_WMSACES',.F.,' ')))
Local lRet     := .F.

   If cAcao=='1'
      cMapCon := mv_par01
   Else
      cMapSep := mv_par01
   EndIf
   cCodSep  := mv_par02
   cEndServ := mv_par03
   cCodConf := mv_par04

   cAliasNew:= GetNextAlias()
   cQuery := " SELECT D12.D12_MAPCON,D12.D12_MAPSEP,D12.D12_RECHUM,D12.R_E_C_N_O_ RECD12 "
   cQuery += " FROM "+RetSqlName('D12')+" D12"
   cQuery += " WHERE D12.D12_FILIAL = '"+xFilial("D12")+"'"
   cQuery += " AND D12.D12_TM > '500'"

   If cAcao=='1'
      If lInclui
         cQuery += " AND D12.D12_RECHUM = '"+cVazio+"'"
      EndIf
      cQuery += " AND D12.D12_MAPCON <> '"+cSemMpCon+"'"
      cQuery += " AND D12.D12_MAPCON = '"+cMapCon+"'"
   Else
      If lInclui
         cQuery += " AND D12.D12_RECHUM = '"+cVazio+"'"
      EndIf
      cQuery += " AND D12.D12_MAPSEP <> '"+cSemMpSep+"'"
      cQuery += " AND D12.D12_MAPSEP = '"+cMapSep+"'"
   EndIf

   cQuery += " AND D12.D_E_L_E_T_ = ' '"
   cQuery += " ORDER BY "+SqlOrder(D12->(IndexKey(IndexOrd())))
   cQuery := ChangeQuery(cQuery)
   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)
   // Atribui o operador e o endereco de servico ao mapa consolidado
   While (cAliasNew)->(!Eof())
      D12->(MsGoTo((cAliasNew)->RECD12))
      RecLock('D12',.F.)
      D12->D12_RECHUM := cCodSep
      D12->D12_ENDCON := cEndServ
      D12->D12_RECCON := cCodConf
      D12->D12_DTGERA := dDataBase
      D12->D12_HRGERA := Time()
      MsUnLock()
      lRet := .T.
      (cAliasNew)->(DbSkip())
   EndDo
   DbSelectArea(cAliasNew)
   DbCloseArea()
   RestArea(aAreaD12)
   If !lRet
      If lInclui
         If cAcao=='1'
            Aviso('WMSA37001',STR0002,{'OK'}) // Mapa consolidado nao encontrado ou o operador ja foi atribuido por outro usuario!
         Else
            Aviso('WMSA37001',STR0003,{'OK'}) // Mapa de separacao nao encontrado ou o operador ja foi atribuido por outro usuario!
         EndIf
      Else
         If cAcao=='1'
            Aviso('WMSA37002',STR0004,{'OK'}) // Mapa consolidado nao encontrado!
         Else
            Aviso('WMSA37002',STR0005,{'OK'}) // Mapa de separacao nao encontrado!
         EndIf
      EndIf
   EndIf
Return NIL