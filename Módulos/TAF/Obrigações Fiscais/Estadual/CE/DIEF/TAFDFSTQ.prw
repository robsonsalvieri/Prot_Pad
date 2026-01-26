#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFDFSTQ           
Gera o registro STQ da DIEF-CE 
Registro tipo STQ - Totais referentes ao estoque

@Param aWizard	->	Array com as informacoes da Wizard

@author David Costa
@since  29/10/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Function TAFDFSTQ( aWizard, cRegime, cJobAux )
Local cNomeReg	:= "STQ"
Local cStrReg		:= ""
Local cTxtSys		:=	CriaTrab( , .F. ) + ".TXT"
Local cAliasQry	:= GetNextAlias()
Local nHandle		:=	MsFCreate( cTxtSys )
Local oLastError := ErrorBlock({|e| AddLogDIEF("Não foi possível montar o registro STQ, erro: " + CRLF + e:Description + Chr( 10 )+ e:ErrorStack)})

Begin Sequence

	QrySTQ( cAliasQry, aWizard )
	
	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	
	If!( cAliasQry )->( Eof() )
		cStrReg	:= cNomeReg
		cStrReg	+= TAFDecimal((cAliasQry)->VL_TRIB, 13, 2, Nil)
		cStrReg	+= TAFDecimal((cAliasQry)->VL_TRIBST, 13, 2, Nil)
		cStrReg	+= TAFDecimal((cAliasQry)->VL_ISEN_NT, 13, 2, Nil)
		cStrReg	+= (cAliasQry)->DT_INV
		cStrReg	+= CRLF 
		
		WrtStrTxt( nHandle, cStrReg )
		
		GerTxtReg( nHandle, cTXTSys, cNomeReg )
		
		( cAliasQry )->( dbCloseArea())
	
	EndIf

	//Status 1 - Indica que o bloco foi encerrado corretamente para processamento Multi Thread
	PutGlbValue( cJobAux , "1" )
	GlbUnlock()
	
Recover
	//Status 9 - Indica ocorrência de erro no processamento
	PutGlbValue( cJobAux , "9" )
	GlbUnlock()

End Sequence

ErrorBlock(oLastError)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} QrySTQ             
Seleciona os dados para geração do registro STQ 

@author David Costa
@since  19/11/2015
@version 1.0
				
/*/
//-------------------------------------------------------------------
Static Function QrySTQ( cAliasQry, aWizard )

Local dDataIni 	:= DToS(aWizard[1][5])
Local dDataFim	:= DToS(aWizard[1][6])
Local cCSTICMSST	:= "10', '30', '70"
Local cCSTICMS	:= "00', '101', '102', '20', '201', '202"
Local cCSTISENNT	:= " 103', '203', '30', '300', '40', '400', '41', '50', '500', '51', '60', '900', '90"

BeginSql Alias cAliasQry

		SELECT TOP 1 C5A_DTINV DT_INV,
		
			/*Itens com cobrança de ICMSST*/
			(SELECT SUM(ITE_TRIBST.C5B_VITEM) VL_TRIBST 
				FROM %table:C5B% ITE_TRIBST
					JOIN %table:C5C% ICMS_ITE_TRIBST
						JOIN %table:C14% CST_ITE_TRIBST
						ON CST_ITE_TRIBST.C14_ID = ICMS_ITE_TRIBST.C5C_CSTICM
							AND CST_ITE_TRIBST.%NotDel% 
							AND CST_ITE_TRIBST.C14_CODIGO IN ( %Exp:cCSTICMSST% )
					ON ICMS_ITE_TRIBST.C5C_ID = ITE_TRIBST.C5B_ID
						AND ITE_TRIBST.C5B_CODITE = ICMS_ITE_TRIBST.C5C_CODITE
						AND ITE_TRIBST.C5B_UNID = ICMS_ITE_TRIBST.C5C_UNID
						AND ITE_TRIBST.C5B_INDPRO = ICMS_ITE_TRIBST.C5C_INDPRO
						AND ITE_TRIBST.C5B_CODPAR = ICMS_ITE_TRIBST.C5C_CODPAR
						AND ICMS_ITE_TRIBST.%NotDel% 
			WHERE ITE_TRIBST.%NotDel% 
				AND ITE_TRIBST.C5B_ID = C5A.C5A_ID AND ITE_TRIBST.C5B_FILIAL = C5A_FILIAL
				) VL_TRIBST,
		
			/*Itens tributados por ICMS*/
			(SELECT SUM(ITE_TRIB.C5B_VITEM) 
				FROM %table:C5B% ITE_TRIB
					JOIN %table:C5C% ICMS_ITE_TRIB
						JOIN %table:C14% CST_ITE_TRIB
						ON CST_ITE_TRIB.C14_ID = ICMS_ITE_TRIB.C5C_CSTICM
							AND CST_ITE_TRIB.%NotDel% 
							AND CST_ITE_TRIB.C14_CODIGO IN ( %Exp:cCSTICMS% )
					ON ICMS_ITE_TRIB.C5C_ID = ITE_TRIB.C5B_ID
						AND ITE_TRIB.C5B_CODITE = ICMS_ITE_TRIB.C5C_CODITE
						AND ITE_TRIB.C5B_UNID = ICMS_ITE_TRIB.C5C_UNID
						AND ITE_TRIB.C5B_INDPRO = ICMS_ITE_TRIB.C5C_INDPRO
						AND ITE_TRIB.C5B_CODPAR = ICMS_ITE_TRIB.C5C_CODPAR
						AND ICMS_ITE_TRIB.%NotDel% 
			WHERE ITE_TRIB.%NotDel% 
				AND ITE_TRIB.C5B_ID = C5A.C5A_ID AND ITE_TRIB.C5B_FILIAL = C5A_FILIAL
			) VL_TRIB,
			
			/*Itens não tributados e isentos*/
			(SELECT SUM(ITE_TRIB.C5B_VITEM) 
				FROM %table:C5B% ITE_TRIB
					JOIN %table:C5C% ICMS_ITE_TRIB
						JOIN %table:C14% CST_ITE_TRIB
						ON CST_ITE_TRIB.C14_ID = ICMS_ITE_TRIB.C5C_CSTICM
							AND CST_ITE_TRIB.%NotDel% 
							AND CST_ITE_TRIB.C14_CODIGO IN ( %Exp:cCSTISENNT% )
					ON ICMS_ITE_TRIB.C5C_ID = ITE_TRIB.C5B_ID
						AND ITE_TRIB.C5B_CODITE = ICMS_ITE_TRIB.C5C_CODITE
						AND ITE_TRIB.C5B_UNID = ICMS_ITE_TRIB.C5C_UNID
						AND ITE_TRIB.C5B_INDPRO = ICMS_ITE_TRIB.C5C_INDPRO
						AND ITE_TRIB.C5B_CODPAR = ICMS_ITE_TRIB.C5C_CODPAR
						AND ICMS_ITE_TRIB.%NotDel% 
			WHERE ITE_TRIB.%NotDel% 
				AND ITE_TRIB.C5B_ID = C5A.C5A_ID AND ITE_TRIB.C5B_FILIAL = C5A_FILIAL
			)VL_ISEN_NT
			
		FROM %table:C5A% C5A
		
		WHERE C5A.%NotDel% 
			AND C5A.C5A_FILIAL = %xFilial:C5A% 
			AND C5A_DTINV BETWEEN %Exp:dDataIni% AND %Exp:dDataFim%
		ORDER BY C5A_DTINV DESC
	EndSql

Return

