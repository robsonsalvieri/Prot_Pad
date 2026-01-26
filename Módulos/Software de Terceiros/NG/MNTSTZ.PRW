#INCLUDE "PROTHEUS.CH"

Function MNTAJUSSTZ()

    Local cAliasQry := GetNextAlias()
    Local cQuery    := ''

    cQuery := 'SELECT '
    cQuery += 'STZ.R_E_C_N_O_ AS REG, '
    cQuery += 'ST91.T9_CODBEM AS CORRETO, '
    cQuery += 'ST92.T9_CODBEM AS INCORRETO '
    cQuery += 'FROM ' + RetSqlName('TQS') + ' TQS '

    cQuery += 'INNER JOIN ' + RetSqlName('ST9') + ' ST91 ON '
    cQuery += NGMODCOMP('ST9','TQS','=', , , 'ST91.T9_FILIAL', 'TQS.TQS_FILIAL' ) + ' '
    cQuery += 'AND ST91.T9_PLACA  = TQS.TQS_PLACA '
    cQuery += "AND ST91.D_E_L_E_T_ = ' ' "

    cQuery += 'INNER JOIN ' + RetSqlName('STZ') + ' STZ ON '
    cQuery += NGMODCOMP('STZ','TQS','=', , , 'STZ.TZ_FILIAL', 'TQS.TQS_FILIAL' ) + ' '
    cQuery += 'AND STZ.TZ_CODBEM = TQS.TQS_CODBEM '
    cQuery += "AND STZ.TZ_TIPOMOV = 'E' "
    cQuery += "AND STZ.D_E_L_E_T_ = ' ' "

    cQuery += 'INNER JOIN ' + RetSqlName('ST9') + ' ST92 ON '
    cQuery += NGMODCOMP('ST9','STZ','=', , , 'ST92.T9_FILIAL', 'STZ.TZ_FILIAL' ) + ' '
    cQuery += 'AND ST92.T9_CODBEM  = STZ.TZ_BEMPAI '
    cQuery += "AND ST92.D_E_L_E_T_ = ' ' "

    cQuery += 'WHERE '
    cQuery += 'TQS.TQS_PLACA <> ST92.T9_PLACA '
    cQuery += "AND TQS.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., 'TOPCONN', TCGENQRY( , , cQuery ), cAliasQry, .F., .T. )

    While (cAliasQry)->(!Eof())

        DbSelectArea( 'STZ' )
		Dbgoto( (cAliasQry)->REG )

        If STZ->TZ_BEMPAI == (cAliasQry)->INCORRETO

            RecLock('STZ', .F.)

                STZ->TZ_BEMPAI := (cAliasQry)->CORRETO

			STZ->( MsUnlock() )

        EndIf

        (cAliasQry)->(DbSkip())

    Enddo


Return .T.

