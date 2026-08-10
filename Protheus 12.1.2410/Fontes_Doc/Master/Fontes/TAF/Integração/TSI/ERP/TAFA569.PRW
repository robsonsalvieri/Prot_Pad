#INCLUDE "TOTVS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

/*/{Protheus.doc} TSIESTSUBS
	(Classe principal para extração de estabelecimentos substitutos - antigo T001AA )
    @type Class
	@author Wesley Pinheiro
	@since 27/07/2020
	@return Nil, nulo, não tem retorno.
/*/
Class TSIESTSUBS

    Data aEstSubst as Array
    Data oJObjTSI  as Object 

    Method New( ) Constructor
    Method LoadParam( )
    Method JSon( )
    Method GetJsn( )

EndClass

/*/{Protheus.doc} New
	(Método contrutor da classe TSIESTSUBS )
    
	@type Class
	@author Wesley Pinheiro
	@since 27/07/2020
	@return Nil, nulo, não tem retorno.
/*/
Method New( cSourceBr ) Class TSIESTSUBS

    Self:LoadParam()
    Self:JSon()

Return

 /*/{Protheus.doc} LoadParam
	(Método responsável por montar Array com Estabelecimentos configurados no parâmetro MV_SUBTRIB
	@author Wesley Pinheiro
	@since  27/07/2020
	@return Nil, nulo, não tem retorno.
/*/
Method LoadParam( ) Class TSIESTSUBS

    Local alSubTri := {}
    if FindFunction( "FAllSubTri" )
        alSubTri := FAllSubTri()
    endif
    self:aEstSubst := alSubTri

Return

 /*/{Protheus.doc} JSon
	(Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI
	@author Wesley Pinheiro
	@since 27/07/2020
	@return Nil, nulo, não tem retorno.
/*/
Method JSon( ) Class TSIESTSUBS

    Local aUf 		:= UfCodIBGE( "", .F. )
    
    Local nI        := 0
    Local nLen      := 0
    Local nUfVld    := 0
    Local nPosI     := 0
    Local nPosF     := 0

    Local cTagMain  := "substituteEstablishment"

    Local oJObjRet  := nil

    oJObjRet := JsonObject( ):New( )

    oJObjRet[cTagMain] := { }

    nAte := Len( self:aEstSubst )

	For nI := 1 To nAte
		nUfVld := Ascan( aUf , { |x| AllTrim( x[1] ) $ AllTrim( self:aEstSubst[nI] ) } )
		
        If nUfVld > 0
			nPosI := At( aUf[nUfVld][1], self:aEstSubst[nI] ) + 2
			nPosF := At( "/", SubStr( self:aEstSubst[nI], nPosI ) ) - 1
			nPosF := IIf( nPosF <= 0, Len( self:aEstSubst[nI] ), nPosF )

            aAdd( oJObjRet[cTagMain],JsonObject( ):New( ) )
            nLen := Len( oJObjRet[cTagMain] )

            oJObjRet[cTagMain][nLen]["branch"]            := Alltrim( cFilAnt ) // 01
            oJObjRet[cTagMain][nLen]["unitFederativeId"]  := aUf[nUfVld][1]     // 02
            oJObjRet[cTagMain][nLen]["stateRegistration"] := SubStr( self:aEstSubst[nI], nPosI, nPosF ) //03
        EndIf

    next nI

    self:oJObjTSI := oJObjRet

    //Comentado mesmo ao atribuir o oJObjRet no self:oJObjTSI, caso faca um FWFreeObj oJObjRet posteriormente, o array no 
    //oJObjTSI ficara vazio devido referencia, ou seja nao existira nenhum json para processar com a linha abaixo habilitada.
    //FWFreeObj( oJObjRet )

Return

 /*/{Protheus.doc} GetJsn 
	(Método responsável retornar a propriedade self:oJObjTSI
	@author Wesley Pinheiro
	@since 27/07/2020
	@return oJObjTSI Objeto da classe TSIESTSUBS
/*/
Method GetJsn() Class TSIESTSUBS
Return self:oJObjTSI

/*----------------------------------------------------------------------
{Protheus.doc} IntEstSubs()
(Teste de extração. Deve ser retirada apos criação do JOB de execução.
@author Wesley Pinheiro
@since 29/07/2020
@return Nil, nulo, não tem retorno.
//----------------------------------------------------------------------*/
Function IntEstSubs()  

    Local oBj    := Nil
    Local oBjAux := Nil

    oBj := TSIESTSUBS( ):new( cEmpAnt + cFilAnt )
    oBjAux := oBj:GetJsn( )
    freeobj( oBj ) 
 
REturn
