#INCLUDE "TOTVS.ch"
#DEFINE NOTA_FISCAL_SERVICE agd.notaFiscalSaidaService.agdNotaFiscalSaidaService
/*/{Protheus.doc} AGDI010
Funcao executada pelo módulo de faturamento ao expedir um documento de saida
@type function
@version 12
@author jean.schulze
@since 22/01/2025
@return variant, nil
/*/
Function AGDI010()
	Local aAreaAtu 		:= GetArea()
    
    if SUPERGETMV("MV_SIGAAGD", .f., .f.)

        dbselectArea( "SD2" ) // Item da NF de Saída
		dbSetOrder( 3 )
		If dbSeek( xFilial( "SD2" ) + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) )
			
            While .Not. SD2->( Eof() ) .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)
    
                cChaveNF := xFilial("SD2") + SD2->( D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM ) 
                oService := NOTA_FISCAL_SERVICE():new(cChaveNF)
                oService:vincularNotaFiscal()
                FreeObj(oService)
    
                SD2->(DBSkip(1))
            end

        endif

    endif

    restarea(aAreaAtu)
Return nil
