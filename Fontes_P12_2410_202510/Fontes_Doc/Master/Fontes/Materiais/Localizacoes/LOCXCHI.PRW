#include 'protheus.ch'
#include 'locxchi.ch'

#Define SAliasHead  4
#Define ScOpFin     9

Static aNfLinkNCC:={}
/*/{Protheus.doc} LxGrvLFChi
	Graba información en la tabla SF3 - Libros Fiscales.
	La función es llamada en GravaNfGeral (LOCXNF.PRW)
    @type  Function
    @author Arturo Samaniego
    @since 28/09/2022
    @param cAlias: Alias de tabla SF1/SF2
    @return Nil
    /*/

Function LxGrvLFChi(cAlias)
Local cKey     := ""
Local aAreaAnt := {}
Local aSF3     := {}

Default cAlias := ""

    If cAlias == "SF1"
        cKey := xFilial("SF3")+SF1->(DtoS(F1_DTDIGIT)+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

        aAreaAnt := GetArea()
        DbSelectArea("SF3")
        aSF3 := SF3->(GetArea())
        SF3->(DbSetOrder(1))
        SF3->(MsSeek(cKey))
        While !SF3->(EOF()) .AND. SF3->(F3_FILIAL+DTOS(F3_ENTRADA)+F3_NFISCAL+F3_SERIE+F3_CLIEFOR+F3_LOJA) == cKey
            RecLock("SF3",.F.)
                Replace F3_RECHON With SF1->F1_RECHON
            MsUnlock()
            SF3->(DbSkip())
        Enddo
        RestArea(aSF3)
        RestArea(aAreaAnt)
    Endif

Return Nil

/*/{Protheus.doc} LxGrvNfChi
	Graba información especifica en notas fiscales del país Chile.
	La función es llamada en GravaNfGeral (LOCXNF.PRW).
    @type  Function
    @author Arturo Samaniego
    @since 28/09/2022
    @param aCfgNF: Array de configuración de nota fiscal.
            lInclui: .T. para la inclusion de documentos.
    @return lRet: .T. si cumple las condiciones.
    /*/
Function LxGrvNfChi(aCfgNF, lInclui)
Local aDadSFE := {}
Local lRet    := .T.
Local cAlias  := ""

Default aCfgNF  := {}
Default lInclui := .F.

    cAlias := aCfgNF[SAliasHead]

    If lInclui .And. cAlias == "SF1" .And. !("NC" $ SF1->F1_ESPECIE)
        If SF1->F1_VALIMP5 >0 ///retencao de honorarios RHO
            Aadd(aDadSFE,{.F.,"",SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,"RHO",0,0,0,SF1->F1_ESPECIE})
            GrvRetSFE(1,aDadSFE)
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} LxDelCCChi
	Actualización de movimientos de caja chica en anulación de documentos fiscales.
	La función es llamada en LocXDelCC (LOCXNF.PRW)
    @type  Function
    @author Arturo Samaniego
    @since 28/09/2022
    @param  cForn: Código del proveedor.
            cLoja: Tienda del proveedor.
            cDoc: Número de documento.
            cSerie: Serie del documento.
            cNroAdia: Número de anticipo.
            nVlrDel: Valor del anticipo.
    @return Nil
    /*/
Function LxDelCCChi(cForn, cLoja, cDoc, cSerie, cNroAdia, nVlrDel)
Local cCx      := ""
Local nValDev  := 0
Local aSldAtu  :={}
Local cFilSET := xFilial("SET")
Local cFilSEU := xFilial("SEU")

Default cForn    := ""
Default cLoja    := ""
Default cDoc     := ""
Default cSerie   := ""
Default cNroAdia := ""
Default nVlrDel  := 0

    cCx := SEU->EU_CAIXA
    SEU->(DbSetOrder(3))
    If SEU->(DbSeek(cFilSEU+cNroAdia))
        While (SEU->(!Eof())) .And. SEU->EU_FILIAL == cFilSEU .And. SEU->EU_NROADIA == cNroAdia
            RecLock("SEU",.F.)
            Replace	SEU->EU_BAIXA With Ctod(" / / ")
            If SEU->EU_TIPO == "02" //devolucao do saldo do adiantamento
                If SEU->EU_FORNECE == cForn .And. SEU->EU_LOJA == cLoja
                    If Alltrim(SEU->EU_NRCOMP) == AllTrim(cDoc) .And. AllTrim(SEU->EU_SERCOMP) == AllTrim(cSerie)
                        nVlrDel += SEU->EU_VALOR
                        nValDev += SEU->EU_VALOR
                        SEU->(DbDelete())
                    Endif
                Endif
            Endif
            MsUnlock()
            SEU->(DbSkip())
        Enddo
        //³ Atualiza saldo do caixinha e niveis superiores, se houverem ³
        If nValDev <> 0
            dbSelectArea("SET")
            dbSetOrder(1)
            MsSeek(cFilSET+cCx)
            aSldAtu := Fa570AtuSld( ET_CODIGO)
            RecLock("SET",.F.)
            REPLACE ET_SALDO WITH aSldAtu[1][1]
            MsUnlock()
        Endif
    Endif

Return Nil


/*/{Protheus.doc} LxNCorrChi
    Disparador del campo F1_NUMCOR/F2_NUMCOR.
    La función es llamada en ChiFillCor (LOCXNF2.PRW)
    @type  Function
    @author Arturo Samaniego
    @since 28/09/2022
    @param cSerie: Serie del documento.
    @return cNumCor: Número correlativo.
    /*/
Function LxNCorrChi(cSerie)
Local aArea    := GetArea()
Local cNumCor  := Criavar('FY_NUMCOR',.F.)
Local dDtDigit := ""
Local lHonora  := .F.
Local cAlias   := aCfgNF[SAliasHead]

Default cSerie := CriaVar("FY_SERIE",.F.)

    If cAlias == "SF1" .And. SubStr(M->F1_ESPECIE,3,1) <> "I" //NF e NDP
        If Type("M->F1_RECHON") <> "U"
            If M->F1_RECHON <> "1"
                lHonora := .F.
            Else
                lHonora := .T.
            Endif
        Endif
    EndIf

    DbSelectArea('SDV')
    SDV->(DbSetOrder(1))
    If SDV->(DbSeek(xFilial('SDV')+subStr(cSerie,1,3)))
        If SDV->DV_GERACOR == "1" .And. !lHonora //Usa Correlativo
            dDtDigit := If(cAlias == "SF1",M->F1_DTDIGIT,M->F2_DTDIGIT)
            cNumCor := CORR_PROX(dDtDigit)
        EndIf
    EndIf

    RestArea(aArea)
Return cNumCor

/*/{Protheus.doc} NfTudOkChi
    La función es llamada en NfTudOk (LOCXNF.PRW)
    @type  Function
    @author Arturo Samaniego
    @since 29/09/2022
    @version version
    @param  aCfgNf: Array con la configuración del documento.
			aDupli: Array con valores financieros.
            nBaseDup: Valor del título financiero de la nota fiscal.
			nMoedaNF: Moneda del documento.
			nMoedaCor: Moneda a convertir el valor.
			nTaxa: Valor de la tasa de cambio.
			l103Class: Indica si existe integración.
            cCxCaixa: Código de caja chica.
            nCxValor: Valor del movimiento de caja chica.
			cFunName: Nombre de la función.
    @return lRet: .T. si cumple con las condiciones.
    /*/
Function NfTudOkChi(aCfgNf, aDupli, nBaseDup, nMoedaNF, nMoedaCor, nTaxa, l103Class, cCxCaixa, nCxValor, cFunName)
Local lRet      := .T.
Local nI        := 0
Local nTotDup   := 0
Local cCentavos := ""

Default aCfgNf    := {}
Default aDupli    := {}
Default nBaseDup  := 0
Default nMoedaNF  := 1
Default nMoedaCor := 1
Default nTaxa     := 0
Default l103Class := .F.
Default cCxCaixa  := ""
Default nCxValor  := 0
Default cFunName  := Funname()

    cCentavos  := Iif(nMoedaNF==1,"MV_CENT",("MV_CENT"+AllTrim(Str(nMoedaNF))))

    // Valida que exista informacion de los titulos cuando la condicion de pago es informada
    If lRet .AND. !l103Class .AND. !Empty(aCfgNf[ScOpFin]) .AND. Len(aDupli) > 0 .AND. nBaseDup > 0 .AND. Val(Alltrim(Extrae(aDupli[1],5)))==0
        Aviso(STR0001,STR0002,{STR0003}) //"ATENCAO"### "Inconsistencias nos valores financeiros"###"OK"
        lRet	:= .F.
    EndIf

    //Controla se o valor total das duplicatas bate com o total
    If lRet .AND. !l103Class .AND. !Empty(aCfgNf[ScOpFin]) .AND. Len(aDupli) > 0 .and. Val(Substr(aDupli[1],rat("³",aDupli[1])+1,len(aDupli[1]))) > 0  // O sistema gera uma estrutura vazia para duplicata.
        For nI := 1 To Len(aDupli)
            nTotDup += DesTrans(Extrae(aDupli[nI],5,))
        Next nI
        If lRet
            If Abs(Round(xMoeda(nBaseDup,nMoedaNF,nMoedaCor,dDataBase,,nTaxa),SuperGetMV(cCentavos,.F.,0)) - nTotDup) > SuperGetMV("MV_LIMPAG")
                Aviso(STR0001,STR0002,{STR0003})				 //"ATENCAO"### "Inconsistencias nos valores financeiros"###"OK"
                lRet	:= .F.
            EndIf
        EndIf
    Endif

    If lRet .And. !Empty(cCxCaixa)
        nCxValor := Round(MaFisRet(,'NF_TOTAL'),MsDecimais( nMoedaNF ))
    EndIf
    
Return lRet

/*/{Protheus.doc} BaixaCxChi
    Actualiza registro de tabla SEU - Caja chica.
    La función es llamada en NFVldCxa (LOCXNF.PRW)
    @type  Function
    @author Arturo Samaniego
    @since 29/09/2022
    @version version
    @param  cAdia: Código de anticipo.
            lAdia: Indica si es anticipo (.T.).
    @return Nil
    /*/
Function BaixaCxChi(cAdia, lAdia)

    If !Empty(cAdia) .And. !lAdia
        SEU->(DbSetOrder(3))
        If SEU->(DbSeek(xFilial("SEU")+cAdia))
            While (SEU->(!Eof())) .And. SEU->EU_FILIAL == xFilial("SEU") .And. SEU->EU_NROADIA == cAdia
                RecLock("SEU",.F.)
                Replace	EU_BAIXA With dDataBase
                MsUnlock()
                SEU->(DbSkip())
            Enddo
        Endif
    Endif

Return Nil


/*/{Protheus.doc} fMontaAux
    Funcion usada para asignar el tipo de acuerdo a selección del parámetro MV_01 del grupo MT101N
    @author adrian.perez
    @since 19/08/2025
    @param nMVPAR, numérico, valor del seleccionado del para metro MV_01
    @return nTipo, numérico, valor del tipo de documento  
    /*/
Function fMontaAux(nMVpar)
Local nTipo:=10
DEFAULT nMVpar:=1

    IF nMVpar== 1 .OR.  nMVPAR== 5
        nTipo:=10
    ELSEIF nMVpar== 2
        nTipo:=12
    ELSEIF nMVpar== 3
         nTipo:=13
    ELSE
       nTipo:=14 
    ENDIF

Return nTipo	
/*/{Protheus.doc} fF12auto
    función usada para determinar si es auto-factura o no al llamar el grupo de preguntas por F12
    @author adrian.perez
    @since 20/08/2025
    @param nMVPAR, numérico, valor del seleccionado del para metro MV_01
    @param lAutoFact, lógico, se pasa por referencia para actualizar indicando si es auto factura o no 
    @param aAutofac, arreglo, se pasa por referencia se actualiza su valor asignando el valor de MV_01
    @return nil
    /*/

Function fF12auto(nMVpar,lAutoFact,aAutofac)

Default nMVpar:=1
Default lAutoFact:=.T.
Default aAutofac:={5}

    IF funname()$"MATA101N" 
        IF nMVpar ==5
            lAutoFact:=.T.
        ELSE
           lAutoFact:=.F.
        ENDIF
        aAutofac[1]:=nMVpar
    ENDIF

Return Nil


/*/{Protheus.doc} fGrvCabCHI
	Funcitón de grabado de encabezado para chile
	@type  Function
	@author adrian.perez
	@since 20/08/2025
    @param cFunName, cadena, indica nombre de la rutina en busca de la MATA101N
    @param aCabNota, arreglo, contiene la informacion de  nombre de campos y valores 
    @param cAlias, cadena, inidca la tabla seleccionada
    @return nil
	/*/
Function fGrvCabCHI(cFunName, aCabNota, cAlias)
Local nPosParAux := 0

Default cFunName := FunName()
Default aCabNota:={}
Default cAlias:=""


	IF (cFunName == "MATA101N") 
		nPosParAux := Ascan(aCabNota[1],{ |x| UPPER(x) == AllTrim("F1_AUTOFAC") } )
		IF nPosParAux<>0
			aCabNota[2][nPosParAux] := cValToChar(aCabNota[2][nPosParAux])
		ENDIF
	ENDIF


Return Nil

/*/{Protheus.doc} fActNFis
    @author adrian.perez
    @since 27/08/2025
    @param cSerie, carácter, serie usada
    @param cMDoc,  carácter, valor a sustituir de M->F1_DOC
    @param cNfdoc, carácter, valor a sustituir de número fiscal
    @param lAutoFact, lógico, indica si es autofactura 
    @return lRet,lógico, indica si encontro la serie

    /*/
Function fActNFis(cSerie,cMDoc,cNfdoc,lAutoFact)

Local aAuxChi	:={}
Local nPosChi   :=0
Local lChkLxProp := FindFunction("ChkLxProp")
Local lRet:=.T.
Default cSerie:=""
Default cMDoc:=""
Default cNfdoc:=""
Default lAutoFact:=.F.

    IF ( ((AllTrim(FunName()) $ "MATA101N") .AND. lAutoFact ) .OR. ( lChkLxProp .AND. ChkLxProp("Autofactura")) )
        aAuxChi:=	FWGetSX5( "01" )
        IF !EMPTY(cSerie) 
            nPosChi:= Ascan(aAuxChi,{|x| ALLTRIM(x[3]) == ALLTRIM(cSerie)})
            IF nPosChi>0
                cNfdoc:=aAuxChi[nPosChi][4]
                cMDoc := cNfdoc  
            ELSE
                Help(" ",1,"A467SERIE")// serie no encontrada en SX5
                lRet:=.f.
            ENDIF
        ENDIF
     nPosChi:=0
	Asize(aAuxChi,0)
    ENDIF
   
	
Return lRet


/*/{Protheus.doc} fNDCchiDat
    Obtiene datos de la NCC vinculada a la NDC a cancelar
    @since 07/09/2025
    @param cTipRef  , carácter, tipo    de documento referenciado
    @param cEspRef  ,carácter, especie de documento referenciado
    @param cSerRef  ,carácter, serie   de documento referenciado
    @param cNCCRef  ,carácter, número  de documento referenciado
    @param cFil     ,carácter, filial
    @param cFornece ,carácter, cliente
     @param cLoja   ,carácter, tienda
    @return aDatNCC, arreglo, contiene los datos de NCC a anaular  
    /*/
Function fNDCchiDat(cTipRef,cEspRef,cSerRef,cNCCRef,cFil,cFornece,cLoja)

Local  aDatNCC     :={}
Local  aLiberado     :={}
Local  cQuery   :=""
Local  cFilSD   :=""
Local  nCampo   :=1
Local  cFilSF   :=""
Local  nI       :=""
Local  nJ       :=""
Local  cProducto:=""
Local  nSum     :=0
Local oExec 	:=Nil
Local   aAuxRep :={}
Local  lRepite  :=.T.
Static aRepetidos:={}

Default cTipRef :=""
Default cEspRef :=""
Default cSerRef :=""
Default cNCCRef :=""
Default cFil    :=""
Default cFornece:=""
Default cLoja   :=""

    If cTipRef=="1" .AND. (ALLTRIM(cEspRef)=="NCC") .AND. !EMPTY(cSerRef) .AND. !EMPTY(cNCCRef)
              /*Datos la NCC*/
            cFilSD := xFilial("SD1",cFil)
            
            cQuery+= " SELECT D1_COD,D1_QUANT LIBERADO,D1_VUNIT,D1_TOTAL,D1_SERIE,D1_NFORI,D1_SERIORI,D1_FORNECE,D1_LOJA,D1_ITEMORI,D1_DOC,D1_ITEM" 
            cQuery+=" FROM "+ RetSqlName("SD1") + "  "
            cQuery+= " WHERE "
          
            cQuery+= "  D1_FILIAL = ? " 
            cQuery+="  AND D1_FORNECE = ? "
            cQuery+= " AND D1_LOJA = ? "
            cQuery+= " AND D1_SERIE =? "
            cQuery+= " AND D1_ESPECIE =? " 
            cQuery+= " AND D1_DOC =? " 
            
            cQuery+= " AND D_E_L_E_T_=?"
            cQuery+= " ORDER BY D1_ITEM DESC "
  
            
		    cQuery := ChangeQuery(cQuery)
			
		    oExec := FwExecStatement():New(cQuery)
		
            oExec:SetString(nCampo++, cFilSD) 
            oExec:SetString(nCampo++, cFornece)
		    oExec:SetString(nCampo++, cLoja) 
            oExec:SetString(nCampo++, cSerRef) 
            oExec:SetString(nCampo++, cEspRef) 
            oExec:SetString(nCampo++, cNCCRef) 
	
		    oExec:SetString(nCampo++, " ") 
	        cAlias := oExec:OpenAlias()

             While !( (cAlias)->(Eof()) ) 
               
                AADD(aDatNCC,{ (cAlias)->D1_COD, 0,(cAlias)->LIBERADO,(cAlias)->D1_NFORI,(cAlias)->D1_SERIORI,(cAlias)->D1_ITEMORI,(cAlias)->D1_DOC,(cAlias)->D1_ITEM,(cAlias)->D1_FORNECE,(cAlias)->D1_LOJA })

            (cAlias)->(DbSkip())
             EndDo
            
            (cAlias)->(DbCloseArea())
        
            oExec:Destroy()
            oExec := nil

        IF len(aDatNCC)>0    
            /*Liberado por NDC de la NCC*/
            cFilSD := xFilial("SD2",cFil)
            cFilSF := xFilial("SF2",cFil)
            nCampo   :=1

            cQuery:="  SELECT SD2.D2_QUANT,SD2.D2_COD,SD2.D2_ITEMORI "
            cQuery+="  FROM "+ RetSqlName("SF2") + "     SF2 "
            cQuery+="  INNER JOIN "+RetSqlName("SD2") +" SD2 ON ""
            cQuery+="  SD2.D2_DOC=SF2.F2_DOC "
            cQuery+="  AND SD2.D2_CLIENTE=SF2.F2_CLIENTE "
            cQuery+="  AND SD2.D2_LOJA=SF2.F2_LOJA "
            cQuery+="  WHERE SF2.F2_NFREF   = ? "
            cQuery+="  AND   SF2.F2_CLIENTE = ? "
            cQuery+="  AND   SF2.F2_LOJA    = ? "
            cQuery+="  AND   SF2.F2_SERIE    = ? "
            cQuery+= " AND   SF2.F2_FILIAL  = ? " 
            cQuery+= " AND   SD2.D2_FILIAL  = ? " 
            cQuery+= " AND SF2.D_E_L_E_T_   = ? "
            cQuery+= " AND SD2.D_E_L_E_T_   = ? "

            
		    cQuery := ChangeQuery(cQuery)
			
		    oExec := FwExecStatement():New(cQuery)
		
 
            oExec:SetString(nCampo++, cNCCRef) 
            oExec:SetString(nCampo++, cFornece)
		    oExec:SetString(nCampo++, cLoja) 
            oExec:SetString(nCampo++, cSerRef) 
            oExec:SetString(nCampo++, cFilSF) 
            oExec:SetString(nCampo++, cFilSD) 
            oExec:SetString(nCampo++, " ") 
		    oExec:SetString(nCampo++, " ") 


	        cAlias := oExec:OpenAlias()

             While !( (cAlias)->(Eof()) ) 
            
                AADD(aLiberado,{ (cAlias)->D2_COD, (cAlias)->D2_QUANT, (cAlias)->D2_ITEMORI})

            (cAlias)->(DbSkip())
             EndDo

            (cAlias)->(DbCloseArea())
        
            oExec:Destroy()
            oExec := nil

            For nI := 1 to len(aDatNCC)
                cProducto:=aDatNCC[nI][1]
                nSum:=0
                For nJ := 1 to len(aLiberado)
                   IF cProducto==aLiberado[nJ][1] .and. (aLiberado[nJ][3]==aDatNCC[nI][8])
                        nSum+=aLiberado[nJ][2]
                   ENDIF
                Next
           
                    aDatNCC[nI][2]:=nSum // liberados en NDC vinculada a la NCC
            Next

            if len(aNfLinkNCC)>0
                aSize(aNfLinkNCC,0)
             endIf
             aNfLinkNCC:= aClone(aDatNCC)
            IF len(aRepetidos)>0
                aSize(aRepetidos,0)
            EndIf
            aAuxRep:=aClone(aDatNCC)

            
            For nI := 1 To Len(aAuxRep)
                lRepite := .F.

                // Verifica si el elemento se repite en otra posición
                For nJ := 1 To Len(aAuxRep)
                    If nI <> nJ .And. aAuxRep[nI][1] == aAuxRep[nJ][1]
                        lRepite := .T.
                        Exit
                    EndIf
                Next

                // Guarda en el arreglo resultado
                AAdd(aRepetidos, {aAuxRep[nI][1], lRepite})
            Next


        
        Endif
    ENdIf

Return aDatNCC

/*/{Protheus.doc} fVallibNCC  Verifica si la cantidad ingresada en la NDC es mayor a la informada en la NDC
    @author adrian.perez
    @since 07/09/2025
    @param nCant, arreglo, cantidad de la NCC a validar
    @param aDatNCC ,arreglo ,valores de los ítems NCC
    @param cItOri,carácter, ítem origen
    @param aCols ,      arreglo, valores de los ítems
    @param nPosCod,	    Numérico,	Posición del código del ítem dentro de cada subarray de aDatNCC.
    @param nPosQuant,	Numérico,	Posición de la cantidad disponible dentro de cada subarray de aDatNCC.
    @param nPosItmOri,	Numérico,	Posición del código del ítem original dentro de cada subarray de aDatNCC.
    @param nI,	        Numérico,	Índice actual del ítem que se está evaluando.
    @return {lRet,nRest}, arreglo, Indica si la cantidad es superior al disponible en la posición 1, y en la posición 2 indica el disponible
    /*/
Function fVallibNCC(nCant,aDatNCC,cItOri,aCols,nPosCod,nPosQuant,nPosItmOri,nI)
Local nPos      := 0
Local lRet      :=.T.
Local nRest     := 0
Local nA        :=0
Local nCanAux      :=0

Default nCant       :=0
Default aDatNCC     :={}
Default cItOri      :=""
Default aCols       :={}
Default nPosCod     :=0
Default nPosQuant   :=0
Default nPosItmOri  :=0
Default nI          :=0

        nPos:=Ascan(aDatNCC,{|x| ALLTRIM(x[8]) == ALLTRIM(cItOri)})   
        IF nPos>0
            nRest:= aDatNCC[nPos][3]-aDatNCC[nPos][2] 
            IF nCant>  nRest
                lRet:=.F.
                Return {lRet,nRest}
            Endif
            
                For nA := 1 To Len(aCols)
                
                    IF  ((aCols[nA][nPosCod]+aCols[nA][nPosItmOri])==  (aDatNCC[nPos][1]+ aDatNCC[nPos][8])) .AND. (!aCols[nI][len(aCols[nI])])
                        nCanAux+=aCols[nA][nPosQuant]
                        if nCanAux>nRest
                            lRet:=.F.
                            Exit
                        endIf
                    ENDIF
                
                Next
        ENDIF
     
Return {lRet,nRest}

/*/{Protheus.doc} fValProNCC Verifica si existe producto en la NCC a dar de baja
    @author adrian.perez
    @since 07/09/2025
    @param cCodProd, carácter, PRODUCTO
    @param aDatNCC , arreglo, valores de los ítems NCC
    @return lRet, boloeano, indica si encontro el producto en la NCC
    /*/
Function fValProNCC(cCodProd,aDatNCC)
Local nPos      :=0
Local lRet      :=.T.

Default cCodProd:=""
Default aDatNCC:={}

        nPos:=Ascan(aDatNCC,{|x| ALLTRIM(x[1]) == ALLTRIM(cCodProd)})    
         IF nPos==0
           lRet      :=.F.
         ENDIF
Return lRet

/*/{Protheus.doc} fClearNDC
    limpia los ítems de la NDC al confirmar venta disparada al cambiar el número(F2_NFREF) de NCC
    @author adrian.perez
    @since 07/09/2025
    @param aHeader, arreglo, campos del encabezado
    @param aCols , arreglo, valores de los ítems
    @param cNfRet , carácter, numero de NCC
    @param aCfgNF , arreglo, datos del documento
    @param oGetDados , objeto, datos del documento 
    @param oBSomaItens , objeto, datos de los items
    @return nil
    /*/
Function fClearNDC(aHeader,aCols,cNfRet,aCfgNF,oGetDados,oBSomaItens)

Local cVarCont	:= ""  // aCfgNF[SAliasCols]
Local cItem		:= ""
Local lZerar	:= .F.
Local nX		:= 0
Local lDel		:=.T.
Local nLin		:= 1
Local lRet      :=  .F.
Local nPosPro   :=0

Static cNFretAnt :=""

Default aHeader     :={}
Default aCols       :={}
Default cNfRet      :=""
Default aCfgNF      :={}
Default oGetDados 	:=Nil
Default oBSomaItens:= Nil

    If  Empty(cNfRet)
        cNFretAnt := ""
        Return NIL
    EndIf

	lZerar	:= (cNFretAnt <> cNfRet) 
	cNFretAnt := cNfRet
    nPosPro:= Ascan(aHeader,{|x| ALLTRIM(x[2]) ==("D2_COD")})
    IF len(aCfgNF)>0
        cVarCont:=Right(aCfgNF[5],2)+"_ITEM" 
    EndiF
 

    If Len(aCols) > 0 .and. !Empty(aCols[1][nPosPro]) .and. lZerar 

        If MsgYesNo(STR0004, STR0005) // STR0004 "Cambio de NCC ¿Desea borrar ítems?"  STR0005 Anulación NCC
                lRet:=.T.
        EndIf

        if lRet 
            aCols := {}
            MaFisClear()
            aAdd(aCols,Array(Len(aHeader)+1))
            For nX := 1 to Len(aHeader)
                If Trim(aHeader[nX][2]) == cVarCont 
                    aCols[Len(aCols)][nX] :=    cItem
                Else//If ( aHeader[nX][10] <> "V")  
                    aCols[Len(aCols)][nX] := CriaVar(aHeader[nX][2],.T.)
                EndIf
                aCols[Len(aCols)][Len(aHeader)+1] := .F.
            Next nX
            oGetDados:Refresh()
            // Limpia pantalla
            lDel := Iif(Len(oBSomaItens:AARRAY)>0,.T.,.F.)
            While lDel
                nLin:= Len(oBSomaItens:AARRAY)
                If Len(oBSomaItens:AARRAY) == 1
                    oBSomaItens:AARRAY[nLin,1] := ''
                    oBSomaItens:AARRAY[nLin,2] := 0
                    lDel:=.F.
                Else
                    Adel(oBSomaItens:AARRAY,nLin)
                    ASize(oBSomaItens:AARRAY,Len(oBSomaItens:AARRAY)-1)
                EndIf
            EndDo

            nTotQtIte:= 0
            oBSomaItens:Refresh()
            ModxAtuObj()
        endIf
        
    endIf

Return NIL

/*/{Protheus.doc} fGuNDanuNC
    Guarda anulación de la NDC vinculada a la NCC
    @author adrian.perez
    @since 08/09/2025
    @param aCabNotaOri, arreglo, nombre de los campos del encabezado
    @param aCpItensOri, arreglo, nombre de los campos de los ítems
    @param aCitensOri , arreglo, valores de los ítems
    @return nil
    /*/
Function fGuNDanuNC(aCabNotaOri,aCpItensOri,aCitensOri)

Local nI:=0
Local nPosQuant:=0
Local nPosTotal:=0
Local nPosProd:=0
Local nPosItOri:=0

Local nPosTPRef:=0
Local nPosNFRef:=0
Local nPosEsRef:=0

Local cNCCRef:=""
Local cTPRef:=""
Local aArea:= {}
Local cKey:=""
Local nNFItOri:=0

Default aCabNotaOri:={}
Default aCpItensOri:={}
Default aCitensOri :={}
   
    nPosTPRef:=Ascan(aCabNotaOri[1],{|x| ALLTRIM(x) == ("F2_TIPREF")})
    cTPRef:=aCabNotaOri[2][nPosTPRef]

    nPosNFRef:=Ascan(aCabNotaOri[1],{|x| ALLTRIM(x) == ("F2_NFREF")})
    cNCCRef:=aCabNotaOri[2][nPosNFRef]

    nPosEsRef:=Ascan(aCabNotaOri[1],{|x| ALLTRIM(x) == ("F2_ESPREF")})
    cEspRef:=aCabNotaOri[2][nPosEsRef]

    If cTPRef== "1" .AND. !EMPTY(cNCCRef) .AND. (ALLTRIM(cEspRef)=="NCC") .AND. (len(aCpItensOri)>0) .AND. (LEN(aNfLinkNCC)>0)

        aArea=getArea()
        nPosProd:=   Ascan(aCpItensOri,{|x| ALLTRIM(x) == ("D2_COD")})
        nPosQuant:=  Ascan(aCpItensOri,{|x| ALLTRIM(x) == ("D2_QUANT")})
        nPosTotal:=  Ascan(aCpItensOri,{|x| ALLTRIM(x) == ("D2_TOTAL")})
        nPosItOri:=  Ascan(aCpItensOri,{|x| ALLTRIM(x) == ("D2_ITEMORI")})
        
        FOR nI:= 1 to len(aCitensOri)
           
            nNFItOri:=   Ascan(aNfLinkNCC,{|x| ALLTRIM(x[8]) == AllTrim(aCitensOri[nI][nPosItOri])})
            IF nNFItOri>0 .AND. (!aCitensOri[nI][len(aCitensOri[nI])])
                cKey:=xFilial("SD2")+aNfLinkNCC[nNFItOri][4]+aNfLinkNCC[nNFItOri][5]+aNfLinkNCC[nNFItOri][9]+aNfLinkNCC[nNFItOri][10]+aCitensOri[nI][nPosProd]+ALLTRIM(aNfLinkNCC[nNFItOri][6])
                DbSelectArea("SD2")
        
                SD2->(DbSetOrder(3)) // 	D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM                                                                                                     
                SD2->(MsSeek( cKey))
                While !SD2->(EOF()) .AND. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM) == cKey
                    RecLock("SD2",.F.)
                        Replace SD2->D2_QTDEDEV With ABS(SD2->D2_QTDEDEV- aCitensOri[nI][nPosQuant])
                        Replace SD2->D2_VALDEV With  ABS(SD2->D2_VALDEV - aCitensOri[nI][nPosQuant])
                    MsUnlock()
                    SD2->(DbSkip())
                Enddo
                SD2->(DbCloseArea())
            ENDIF
        NEXT 
        RestArea(aArea)
        aSize(aArea,0)
    ENDIF

Return nil

/*/{Protheus.doc} LxLOkCHI
    Validaciones de línea del documento fiscal.
    La función es llamada en NfLinOk (LOCXNF.PRW)
    @adrian.perez
    @since 18/09/2025
    @param aCols     , arreglo, Ítems de documento fiscal
    @param nI         ,numérico, numero de línea
    @param cEspecie   ,carácter,  Especie del documento.
    @param nPosNFOri  ,numérico, posición correspondiente al campo D2_NFORI   (numero de la NCC origen)
    @param nPosSerOri ,numérico, posición correspondiente al campo D2_SERORI  (Serie de la NCC origen)
    @param nPosItmOri ,numérico, posición correspondiente al campo D2_ITEMORI (Item de la NCC origen)
    @param nPosCod    ,numérico, posición correspondiente al campo D2_COD     (código producto)
    @param nPosQuant  ,numérico, posición correspondiente al campo D2_QUANT     (cantidad producto)
    @return lRet      ,booleano , indica si hubo un impedimento para seguir sobre la línea 

    /*/
Function LxLOkCHI(aCols, nI,cEspecie,  nPosNFOri, nPosSerOri,nPosItmOri,nPosCod,nPosQuant)
Local lRet:=.T.
Local nNCCOri:=0
Local cAux := ""
Default aCols       :={} 
Default nI          :=0 
Default cEspecie    :=""
Default nPosNFOri   :=0 
Default nPosSerOri  := 0
Default nPosItmOri  :=0
Default nPosCod     :=0
Default nPosQuant   :=0

    IF (len(aCols)>0) .AND.  (nI>0) .AND. (cEspecie $ "NDC" ) .AND. (nPosNFOri>0) .AND. (nPosSerOri>0) .AND. (nPosItmOri>0) .AND. (LEN(aNfLinkNCC)>0)
       
        nNCCOri:=   Ascan(aNfLinkNCC,{|x| ALLTRIM(x[1]) == AllTrim(aCols[nI][nPosCod])})
        IF nNCCOri>0
            aCols[nI][nPosNFOri]:=aNfLinkNCC[nNCCOri][7]
            M->D2_NFORI:= aNfLinkNCC[nNCCOri][7]
            MafisAlt("IT_NFORI",M->D2_NFORI,nI)

            aCols[nI][nPosSerOri]:=aNfLinkNCC[nNCCOri][5]
            M->D2_SERORI:= aNfLinkNCC[nNCCOri][5]
            MafisAlt("IT_SERORI",M->D2_SERORI,nI)

            IF EMPTY(aCols[nI][nPosItmOri]) 
                IF  LEN(aRepetidos)>0
                    IF aRepetidos[nNCCOri][2] 
                        cAux:=STR0008 //STR0008 "Informar manualmente el campo 'Item Doc.Ori' para identificar el ítem, buscar dato en el campo 'Item ' de la NCC "
                        Help(" ",1,STR0005,,STR0009,2,3,,,,,,{cAux}) //STR0005 "Anulación NCC ", STR0009 "Existe el producto en varios ítems de la NCC"
                        lRet:=.F.
                    ELSE

                        aCols[nI][nPosItmOri]:=aNfLinkNCC[nNCCOri][8] // Se llena en automatico
                        M->D2_ITEMORI:= aNfLinkNCC[nNCCOri][8]
                        lRet:=  fValCant( aCols[nI][nPosQuant],aNfLinkNCC,aCols[nI][nPosItmOri],aCols,nPosCod,nPosQuant,nPosItmOri,nI)
                    ENDIF
                ENDIF
            ELSE
               nNCCOri:= Ascan(aNfLinkNCC,{|x| ALLTRIM(x[8]) == AllTrim(aCols[nI][nPosItmOri])})
               IF nNCCOri==0
                    cAux:= STR0011 //+ ALLTRIM(cNCCRef) //STR0006 "Verifique las liberaciones previas de la NCC " 
                    Help(" ",1,STR0005,,STR0010,2,3,,,,,,{cAux})  // STR0005 Anulación NCC  STR0010 "No existe el 'Item Doc.Ori'en la NCC vinculada"
                    lRet:=.F.
                ELSE
                    lRet:=  fValCant( aCols[nI][nPosQuant],aNfLinkNCC,aCols[nI][nPosItmOri],aCols,nPosCod,nPosQuant,nPosItmOri,nI) 
                   
                ENDIF
              
            ENDIF
            

            If Type("oGetDados")=="O" .AND. lRet
                oGetDados:oBrowse:Refresh()
            EndIf
            IF nNCCOri!=0
                if !lRet .AND. !aRepetidos[nNCCOri][2] 
                aCols[nI][nPosItmOri]:=""
                M->D2_ITEMORI:= ""
                EndIf
            EndIf
        ENDIF
       
    ENDIF

Return lRet


/*/{Protheus.doc} fValCant
     Verifica si la cantidad ingresada en la NDC es mayor a la informada en la NDC llamando a fVallibNCC
    @author adrian.perez
    @since 22/09/2025
    @param nCant, arreglo, cantidad de la NCC a validar
    @param aDatNCC ,arreglo ,valores de los ítems NCC
    @param cItOri,carácter, ítem origen
    @param aCols ,      arreglo, valores de los ítems
    @param nPosCod,	    Numérico,	Posición del código del ítem dentro de cada subarray de aDatNCC.
    @param nPosQuant,	Numérico,	Posición de la cantidad disponible dentro de cada subarray de aDatNCC.
    @param nPosItmOri,	Numérico,	Posición del código del ítem original dentro de cada subarray de aDatNCC.
    @param nI,	        Numérico,	Índice actual del ítem que se está evaluando.
    @return lRet,       booleano,   Indica si la cantidad es mayor a la ya liberada si es mayor regresa falso
    /*/

Function fValCant(nCant,aDatNCC,cItOri,aCols,nPosCod,nPosQuant,nPosItmOri,nI)
Local lRet:=.T.  
Local aAux:={}
Local cAux:=""

Default nCant       :=0
Default aDatNCC     :={}
Default cItOri      :=""
Default aCols       :={}
Default nPosCod     :=0
Default nPosQuant   :=0
Default nPosItmOri  :=0
Default nI          :=0

        if len(aDatNCC)>0 
           aAux:= fVallibNCC(nCant,aDatNCC,cItOri,aCols,nPosCod,nPosQuant,nPosItmOri,nI) 
           if len(aAux)>0
                IF !aAux[1]
                    
                    cAux:= STR0006 +" "+STR(aAux[2])//+ ALLTRIM(cNCCRef) //STR0006 "Verifique que el total no sea mayor al disponible de "   
                    Help(" ",1,STR0005,,STR0007+" "+STR(aAux[2]),2,3,,,,,,{cAux}) // STR0005 "Anulación NCC ", STR0019 Anulación NCC  STR0007 "La cantidad del producto es superior al disponible de"
                    lRet:=aAux[1]
                EndIf
            EndIf
        endIf
Return lRet
