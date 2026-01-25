#include "protheus.ch"
#include "Birtdataset.ch"
#include "TOPCONN.CH"

/*/{Protheus.doc} RUBIRT001()
    (long_description)
    @type  Function
    @author ILomonosov
    @since 10.12.2020
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
    Function RUBIRT001(aTMP as array) // ????? ??????? ? ?? ??????
    //????????? ?????????? ?????? ???? ? ???? ??? ????? Mvpar, ????? ????????? ???????????
    local aSingers as array
    local aCData   as array
        
        aSingers :={}

        aCData :={}
        // While (aTMP)->(!Eof()) 
            IF !empty(cMvpar)
                aadd(aSingers,Signers(cMvpar))
            ENDIF
            
        //????????? ?????????? ?????? ???? ? ???? ??? ????? Adress, ????? ????????? ??????
            
            IF !empty(cAddrKey)
                aadd(aCData,Adress(cAddrKey,'0'))
            ENDIF

        // End
    Return

/*/{Protheus.doc} Signers
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
    Function Signers(cMvpar)

        Local aSingers as array
        Local cDESCSU as Char
        Local cRNome as Char
        Local cRANome as Char
        Local cAliasTM as Char
        Local cQuery as Char
        local cMvparN as Char

	aCData1 := GetCoBrRUS(cSelFil)

        aSingers := {}
        IF cMvparN==''
            cRANome := ''
            cDESCSU := ''
        ELSE	
            cQuery := "SELECT DISTINCT F42_NAME, Q3_DESCSUM "
            cQuery += "FROM " + RetSqlName("F42") + " F42 " 
            cQuery += "INNER JOIN " + RetSqlName("SRA") + " SRA " 
            cQuery += "ON F42.F42_EMPL = SRA.RA_MAT " 
            cQuery += " and SRA.RA_FILIAL = '"+xFilial('SRA')+"' "

            cQuery += "INNER JOIN " + RetSqlName("SQ3") + " SQ3 " 
            cQuery += "ON F42.F42_CARGO = SQ3.Q3_CARGO "
            cQuery += " and SQ3.Q3_FILIAL = '"+xFilial('SQ3')+"' "

            cQuery += "WHERE SRA.RA_MAT = '" + cMvparN + "' " 
            cQuery += "AND F42.F42_EMPL = '" + cMvparN + "' " 
            cQuery += "AND F42.F42_REPORT IN('TORG-1','ALL') "
            cQuery += "AND F42.D_E_L_E_T_=' ' "
            cQuery += "AND SRA.D_E_L_E_T_=' ' "
            cQuery += "AND SQ3.D_E_L_E_T_=' '"

            cQuery := ChangeQuery(cQuery)

            cAliasTM := GetNextAlias()

            dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTM,.T.,.T.)
            DbSelectArea(cAliasTM)
            (cAliasTM)->(DbGoTop())
            cDESCSU := alltrim((cAliasTM)->Q3_DESCSUM)
            cRNome := alltrim((cAliasTM)->F42_NAME)

            cRANome := alltrim(substr(alltrim(cRNome),1,(at(' ',alltrim(cRNome),1))))
            cRANome += ' ' + alltrim(substr(alltrim(cRNome),(at(' ',alltrim(cRNome),1)),2))
            cRANome += '.' + alltrim(substr(alltrim(cRNome),(at(' ',alltrim(cRNome),len(cRANome))),2)) +'.'		
            (cAliasTM)->(dbCloseArea())

        ENDIF

    Return 

/*/{Protheus.doc} Address
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
    Function Address(cAddrKey)

        Local cAgaFull     AS Char
        Local cTab         AS Char
        Local aAreaTMPTAB  AS ARRAY
        aAreaTMPTAB := {}
        aCurAddrs 	:= {}
        
        cQuery := "SELECT AGA_CEP, AGA_BAIRRO, AGA_END, AGA_HOUSE, AGA_BLDNG, AGA_APARTM, AGA_MUNDES "
        cQuery += "FROM " + RetSQLName("AGA") + " AGA "
        cQuery += "WHERE AGA_TIPO = '" + cType +  "' AND AGA_ENTIDA = 'SM0' "
        cQuery += "AND AGA_CODENT LIKE '%" + cAddrKey + "%'"
        cQuery += " and AGA_FILIAL = '"+xFilial('AGA')+"' "

        cTab := CriaTrab( , .F.)

        TcQuery cQuery NEW ALIAS ((cTab))
        
        DbSelectArea((cTab))
        aAreaTMPTAB := (cTab)->(GetArea())

        cAgaFull := alltrim((cTab)->AGA_CEP)
        cAgaFull += ", " + alltrim((cTab)->AGA_BAIRRO) + alltrim((cTab)->AGA_MUNDES)
        cAgaFull += ", " + alltrim((cTab)->AGA_END) + ", " + alltrim((cTab)->AGA_HOUSE)
        cAgaFull += ", " + alltrim((cTab)->AGA_BLDNG) + ", " + alltrim((cTab)->AGA_APARTM)

        RestArea(aAreaTMPTAB)

    Return cAgaFull                   
//Merge Russia R14 
                   
