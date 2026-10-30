#include 'protheus.ch'
#include 'locxchi.ch'

#Define SAliasHead  4
#Define ScOpFin     9


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

Local aDatNCC:={}

Default cTipRef :=""
Default cEspRef :=""
Default cSerRef :=""
Default cNCCRef :=""
Default cFil    :=""
Default cFornece:=""
Default cLoja   :=""

   
    If FindFunction("fNDCDATANU")

     aDatNCC:= fNDCDATANU(cTipRef,cEspRef,cSerRef,cNCCRef,cFil,cFornece,cLoja)

    EndIf

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
Local aRet      := {}


Default nCant       :=0
Default aDatNCC     :={}
Default cItOri      :=""
Default aCols       :={}
Default nPosCod     :=0
Default nPosQuant   :=0
Default nPosItmOri  :=0
Default nI          :=0

    If FindFunction("fNCCVALLIB")

     aRet:= fNCCVALLIB(nCant,aDatNCC,cItOri,aCols,nPosCod,nPosQuant,nPosItmOri,nI)

    ENDIF
     
Return aRet

/*/{Protheus.doc} fValProNCC Verifica si existe producto en la NCC a dar de baja
    @author adrian.perez
    @since 07/09/2025
    @param cCodProd, carácter, PRODUCTO
    @param aDatNCC , arreglo, valores de los ítems NCC
    @return lRet, boloeano, indica si encontro el producto en la NCC
    /*/
Function fValProNCC(cCodProd,aDatNCC)

Local lRet      :=.T.

Default cCodProd:=""
Default aDatNCC:={}

    If FindFunction("fNCCVALPRO")
        lRet:= fNCCVALPRO(cCodProd,aDatNCC)
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



Default aHeader     :={}
Default aCols       :={}
Default cNfRet      :=""
Default aCfgNF      :={}
Default oGetDados 	:=Nil
Default oBSomaItens:= Nil

    If FindFunction("fNDCClear")

        fNDCClear(aHeader,aCols,cNfRet,aCfgNF,oGetDados,oBSomaItens)
        
    ENDIF

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



Default aCabNotaOri:={}
Default aCpItensOri:={}
Default aCitensOri :={}
   
    If FindFunction("fNCCANUGU")

        fNCCANUGU(aCabNotaOri,aCpItensOri,aCitensOri)
        
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

Default aCols       :={} 
Default nI          :=0 
Default cEspecie    :=""
Default nPosNFOri   :=0 
Default nPosSerOri  := 0
Default nPosItmOri  :=0
Default nPosCod     :=0
Default nPosQuant   :=0
    
    If FindFunction("fNCCOKANU")
      lRet:=  fNCCOKANU(aCols, nI,cEspecie,  nPosNFOri, nPosSerOri,nPosItmOri,nPosCod,nPosQuant)
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

Default nCant       :=0
Default aDatNCC     :={}
Default cItOri      :=""
Default aCols       :={}
Default nPosCod     :=0
Default nPosQuant   :=0
Default nPosItmOri  :=0
Default nI          :=0
      
       If FindFunction("fCanValNDC")
        lRet:= fCanValNDC(nCant,aDatNCC,cItOri,aCols,nPosCod,nPosQuant,nPosItmOri,nI)
       ENDIF

Return lRet

