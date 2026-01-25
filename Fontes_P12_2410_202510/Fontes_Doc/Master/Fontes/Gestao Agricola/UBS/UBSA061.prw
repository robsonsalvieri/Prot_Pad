#INCLUDE "UBSA061.CH"
#INCLUDE "PROTHEUS.CH" 

/*/{Protheus.doc} UBSA060
Manutenção do termo de conformidade
@type function
@version  P12
@author Daniel Silveira / claudineia.reinert
@since 24/11/2023
/*/
Function UBSA061()
   	Local oMBrowse 		:= Nil
	Local cFiltroDef 	:= "NNN_TIPO <> 'N'"

	If .not. UBSC060DIC()
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	EndIf

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NNN" )
	oMBrowse:SetDescription( STR0001 ) //##"Manutenção Termo Aditivo"
	oMBrowse:SetFilterDefault( cFiltroDef )
	oMBrowse:SetMenuDef( "UBSA061" )
	oMBrowse:DisableDetails()
	oMBrowse:SetAttach( .T. ) 
	oMBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Menu da rotina
@type function
@version  P12
@author claudineia.reinert
@since 24/11/2023
/*/
Static Function MenuDef()
	Local aRotina 	:= {}
	aAdd( aRotina, { STR0002    , "UBSA061IMP"  	, 0, 2, 0, Nil } ) //"Imprimir Termo"
	aAdd( aRotina, { STR0003	, "UBSA061EXC"  	, 0, 5, 0, Nil } ) //"Excluir Termo"
	aAdd( aRotina, { STR0004   	, "UBSA061HIS"      , 0, 7, 0, Nil } ) //"Histórico"  	
	
Return( aRotina )

/*/{Protheus.doc} UBSA060EXC
Função para Excluir o termo de conformidade
@type function
@version  P12
@author Daniel Silveira / claudineia.reinert
@since 23/11/2023
/*/
Function UBSA061EXC()

    Local cQryExc := GetNextAlias()

    If AGRGRAVAHIS(STR0005 + alltrim(NNN->NNN_NUM) + " ?","NNN",cFilAnt+NNN->NNN_NUM+NNN->NNN_CODSAF+NNN->NNN_TIPO,"5") = 1 //##"Confirma a exclusão do termo aditivo "
		
        BEGINSQL Alias cQryExc
            select NP9_FILIAL, NP9_CODSAF, NP9_PROD, NP9_LOTE 
            from %Table:NP9% NP9
            where NP9.D_E_L_E_T_=' ' 
            AND NP9_FILIAL= %xFilial:NP9%
            AND NP9_CODSAF = %Exp:NNN->NNN_CODSAF%
            AND NP9_NTERMC = %Exp:NNN->NNN_NUM%
			AND NP9_TIPOTE = %Exp:NNN->NNN_TIPO%
			AND NP9_PROD   = %Exp:NNN->NNN_CODPRO%
        ENDSQL
		
	    BEGIN TRANSACTION
			DbSelectArea("NP9")
			NP9->(DBSETORDER(1))
			while !(cQryExc)->(Eof())
				If NP9->(DBSEEK( xFilial("NP9") +(cQryExc)->NP9_CODSAF + (cQryExc)->NP9_PROD + (cQryExc)->NP9_LOTE))
					Reclock("NP9", .F.)
					NP9->NP9_NTERMC := ""
					NP9->NP9_TIPOTE := ""
					NP9->(MsUnLock())
				endif
				(cQryExc)->(DbSkip())
			enddo
			NP9->(DBCLOSEAREA())

			Reclock("NNN", .F.)
			DbDelete()
			MsUnlock()
		end TRANSACTION
		FwAlertSucess(STR0006) //##"Termo excluído com Sucesso."
    ENDIF

Return()

/*/{Protheus.doc} UBSA060IMP
 	Função para buscar os dados e realizar a reimpressão do termo de conformidade
    @type  Function
    @author Daniel Silveira/claudineia.reinert
	@since 23/11/2023
/*/
Function UBSA061IMP()
	Local aAux := {}
	Local aDados := {}
    Local cAliasTer := GetNextAlias()
    Local cCodTerm  := NNN->NNN_NUM
	Local cTerSafra := NNN->NNN_CODSAF
	Local cTerCultr := NNN->NNN_CULTRA
	Local cTerCtvar := NNN->NNN_CTVAR
	Local cTerCateg := NNN->NNN_CATEG
	Local cTerResp  := NNN->NNN_RESTEC
	Local dDataTerm	:= NNN->NNN_DATA
	Local cTerProd	:= NNN->NNN_CODPRO
	Local cTipoAdt	:= NNN->NNN_TIPO
	Local aObsTrat	:= {}

	//## Variaveis para a função de impressão - caso mudar as posições abaixo ajustar tambem no fonte UBSC061 ##
	Private _nPosLote 	:= 1 //numero do lote
	Private _nPosSafr 	:= 2 //numero do lote
	Private _nPosDataLT := 3 //data do lote
	Private _nPosPrdTR 	:= 4 //produto do lote tratado/reembalado
	Private _nPosQtTR 	:= 5 //qtd lote NP9 tratado/reembalado
	Private _nPosPMETR 	:= 6 //Peso Medio Ensaque tratado/reembalado      
	Private _nPosPMSTR  := 7 //Peso de Mil Sementes tratado/reembalado     
	Private _nPosBole 	:= 8 //numero boletim
	Private _nPosDtBl 	:= 9 //data boletim
	Private _nPosCert 	:= 10 //numero certificado
	Private _nPosDtCt 	:= 11 //data certificado
	Private _nPosPrdOri := 12 //produto origem
	Private _nPosPMEOri := 13 //peso medio ensaque do lote origem
	Private _nPosQtOri 	:= 14 //Quantidade do lote origem
	Private _nTCmfeOri	:= 15 //numero termo conformidade origem
	Private _DTCmfeOri	:= 16 //data termo conformidade origem
		
    BEGINSQL Alias cAliasTer
        SELECT distinct NP9_FILIAL, NP9_CODSAF, NP9_PROD, NP9_PRDDES, NP9_LOTE
		FROM %Table:NP9% NP9
		WHERE NP9.D_E_L_E_T_ = ' ' 
		AND NP9_FILIAL   = %xFilial:NP9%
		AND NP9_CODSAF   = %Exp:cTerSafra%
		AND NP9_CTVAR    = %Exp:cTerCtvar%
		AND NP9.NP9_PROD = %Exp:cTerProd%
		AND NP9_NTERMC   = %Exp:cCodTerm%	
		AND NP9_TIPOTE   = %Exp:NNN->NNN_TIPO%
    ENDSQL

	While !(cAliasTer)->(Eof())
		aAux := {}	
		aAux := UBSC061BDL((cAliasTer)->NP9_CODSAF , (cAliasTer)->NP9_LOTE, (cAliasTer)->NP9_PROD, @cTipoAdt, cCodTerm)
		If LEN(aAux) > 0 
			aadd(aDados, aAux)
			IF EXISTBLOCK("UBSC61NR")
				aRetPe := ExecBlock("UBSC61NR",.F.,.F.,{cCodTerm,cTipoAdt,aDados})
				If ValType(aRetPe) == "A" .And. Len(aRetPe) == 3 .And. ValType(aRetPe[1]) == "L" .And. ValType(aRetPe[2]) == "C" .And. ValType(aRetPe[3]) == "A" 
					aObsTrat	:= aClone(aRetPe[3])
				EndIf			
			endif
		EndIf
		(cAliasTer)->(dbSkip())
	Enddo
	If len(aDados) > 0
  		FWMsgRun(, {|| UBSC061A(aDados,cCodTerm, cTerResp, cTerSafra, cTerCultr, cTerCtvar, cTerCateg, cTipoAdt, dDataTerm, aObsTrat) }, STR0007, STR0008) //##"Gerando Termo Aditivo" //"Processando..."
	EndIf
return .T.

/*/{Protheus.doc} UBSA060HIS
Mostra tela com o Historico do termo de conformidade
@type function
@version P12  
@author claudineia.reinert
@since 23/11/2023
/*/
Function UBSA061HIS()
	Local cChaveI := "NNN->("+Alltrim(AGRSEEKDIC("SIX","NNN",1,"CHAVE"))+")"
	Local cChaveA := &(cChaveI)+Space(Len(NK9->NK9_CHAVE)-Len(&cChaveI))

	AGRHISTTABE("NNN",cChaveA)
Return
