<?xml version='1.0' encoding='ISO-8859-1' ?>
<xsl:stylesheet version = "2.0" xmlns:xsl = "http://www.w3.org/1999/XSL/Transform">
    <xsl:template match = "/">
        <html>
            <style type = "text/css">
                table, tr, td, th{
                border:1px solid #555;
                margin:0;
                padding:0;
                }
            </style>
            <body>
                <h1 Align = "Left">
                    <font face = "Verdana" Size = "3">
                        <b>Booking Summary</b>
                    </font>
                </h1>
                <font face = "Verdana" Size = "2">
                    <b>Booking Number:</b>
                </font>
                <font face = "Verdana " Size = "2">
                    <xsl:value-of select = "Message/MessageBody/MessageProperties/ReferenceInformation[@ReferenceType='BookingNumber']"/>
                </font>
                <br>
                    <font face = "Verdana" Size = "2">
                        <b>INTTRA Booking Number:</b>
                    </font>
                    <font face = "Verdana" Size = "2">
                        <xsl:value-of select = "Message/MessageBody/MessageProperties/ReferenceInformation[@ReferenceType='INTTRABookingNumber']"/>
                    </font>
                </br>
                <br>
                    <font face = "Verdana" Size = "2">
                        <b>Contract Number:</b>
                    </font>
                    <font face = "Verdana" Size = "2">
                        <xsl:value-of select = "Message/MessageBody/MessageProperties/ReferenceInformation[@ReferenceType='ContractNumber']"/>
                    </font>
                </br>
                <br>
                    <font face = "Verdana" Size = "2">
                        <b>Shippers Reference:</b>
                    </font>
                    <font face = "Verdana" Size = "2">
                        <xsl:value-of select = "Message/MessageBody/MessageProperties/ReferenceInformation[@ReferenceType='ShipperIdentifyingNumber']"/>
                    </font>
                </br>
                <br>
                    <font face = "Verdana" Size = "2">
                        <b>Purchase Order:</b>
                    </font>
                    <font face = "Verdana" Size = "2">
                        <xsl:value-of select = "Message/MessageBody/MessageProperties/ReferenceInformation[@ReferenceType='PurchaseOrderNumber']"/>
                    </font>
                </br>
                <br>
                    <font face = "Verdana" Size = "2">
                        <b>Freight Forwarder Reference:</b>
                    </font>
                    <font face = "Verdana" Size = "2">
                        <xsl:value-of select = "Message/MessageBody/MessageProperties/ReferenceInformation[@ReferenceType='FreightForwarderReference']"/>
                    </font>
                </br>
                <p></p>
                <table
                    WIDTH = "100%"
                    cellpading = "0"
                    cellspacing = "0">
                    <Left>
                        <tr>
                            <th colspan = "2" Align = "LEFT">
                                <font face = "Verdana" Size = "2">CARGO INFORMATION</font>
                            </th>
                        </tr>
                    </Left>
                    <tr>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Cargo Description</font>
                        </th>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Estimated Total Cargo Wgt (in Kg)</font>
                        </th>
                    </tr>
                    <xsl:for-each select = "Message/MessageBody/MessageDetails/GoodsDetails">
                        <tr>
                            <td>
                                <xsl:choose>
                                    <xsl:when test = "PackageDetailComments !=''">
                                        <font face = "Verdana" Size = "1">
                                            <xsl:value-of select = "PackageDetailComments"/>
                                        </font>
                                    </xsl:when>
                                    <xsl:otherwise>--</xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test = "PackageDetailWeight !=''">
                                        <font face = "Verdana" Size = "1">
                                            <xsl:value-of select = 'format-number(PackageDetailWeight, "#######")'/>
                                        </font>
                                    </xsl:when>
                                    <xsl:otherwise>--</xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
                <p></p>
                <table
                    width = "100%"
                    cellpading = "0"
                    cellspacing = "0">
                    <tr>
                        <th colspan = "5" Align = "LEFT">
                            <font face = "Verdana" Size = "2">CONTAINER INFORMATION</font>
                        </th>
                    </tr>
                    <tr>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Quantity</font>
                        </th>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Equipament Code</font>
                        </th>
                    </tr>
                    <xsl:for-each select = "Message/MessageBody/MessageDetails/EquipmentDetails">
                        <tr>
                            <td>
                                <font face = "Verdana" Size = "1"></font>
                                <xsl:choose>
                                    <xsl:when test = "EquipmentCount !=''">
                                        <font face = "Verdana" Size = "1">
                                            <xsl:value-of select = "EquipmentCount"/>
                                        </font>
                                    </xsl:when>
                                    <xsl:otherwise>--</xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test = "EquipmentType/EquipmentTypeCode !=''">
                                        <font face = "Verdana" Size = "1">
                                            <xsl:value-of select = "EquipmentType/EquipmentTypeCode"/>
                                        </font>
                                    </xsl:when>
                                    <xsl:otherwise>--</xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
                <p></p>
                <table
                    width = "100%"
                    cellpading = "0"
                    cellspacing = "0">
                    <tr>
                        <th colspan = "5" Align = "LEFT">
                            <font face = "Verdana" Size = "2">ROUTING</font>
                        </th>
                    </tr>
                    <tr>
                        <th colspan = "5" Align = "LEFT">
                            <font face = "Verdana" Size = "1">Move Type:</font>
                            <xsl:choose>
                                <xsl:when test = "Message/MessageBody/MessageProperties/HaulageDetails/@MovementType !=''">
                                    <font face = "Verdana" Size = "1">
                                        <xsl:value-of select = "Message/MessageBody/MessageProperties/HaulageDetails/@MovementType"/>
                                    </font>
                                </xsl:when>
                                <xsl:otherwise>--</xsl:otherwise>
                            </xsl:choose>
                        </th>
                    </tr>
                    <tr>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Place</font>
                        </th>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Location Code</font>
                        </th>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Location</font>
                        </th>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Date</font>
                        </th>
                    </tr>
                    <xsl:for-each select = "Message/MessageBody/MessageProperties/TransportationDetails/Location">
                        <tr>
                            <td>
                                <xsl:choose>
                                    <xsl:when test = "@LocationType !=''">
                                        <font face = "Verdana" Size = "1">
                                            <xsl:value-of select = "@LocationType"/>
                                        </font>
                                    </xsl:when>
                                    <xsl:otherwise>--</xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test = "LocationCode !=''">
                                        <font face = "Verdana" Size = "1">
                                            <xsl:value-of select = "LocationCode"/>
                                        </font>
                                    </xsl:when>
                                    <xsl:otherwise>--</xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test = "LocationName !=''">
                                        <font face = "Verdana" Size = "1">
                                            <xsl:value-of select = "LocationName"/>
                                        </font>
                                    </xsl:when>
                                    <xsl:otherwise>--</xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <font face = "Verdana" Size = "1">
                                    <xsl:value-of select = "concat(substring(DateTime,7,2),'-',substring(DateTime,5,2),'-',substring(DateTime,1,4))"/>
                                </font>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
                <p></p>
                <table
                    width = "100%"
                    cellpading = "0"
                    cellspacing = "0">
                    <tr>
                        <th colspan = "5" Align = "LEFT">
                            <font face = "Verdana" Size = "2">TRANSPORTATION DETAILS</font>
                        </th>
                    </tr>
                    <tr>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Conveyance Name</font>
                        </th>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Voyage Trip Number</font>
                        </th>
                    </tr>
                    <xsl:for-each select = "Message/MessageBody/MessageProperties/TransportationDetails/ConveyanceInformation">
                        <tr>
                            <td>
                                <xsl:choose>
                                    <xsl:when test = "ConveyanceName !=''">
                                        <font face = "Verdana" Size = "1">
                                            <xsl:value-of select = "ConveyanceName"/>
                                        </font>
                                    </xsl:when>
                                    <xsl:otherwise>--</xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test = "VoyageTripNumber !=''">
                                        <font face = "Verdana" Size = "1">
                                            <xsl:value-of select = "VoyageTripNumber"/>
                                        </font>
                                    </xsl:when>
                                    <xsl:otherwise>--</xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
                <p></p>
                <table
                    width = "100%"
                    cellpading = "0"
                    cellspacing = "0">
                    <tr>
                        <th colspan = "5" Align = "LEFT">
                            <font face = "Verdana" Size = "2">ADDITIONAL INFORMATION</font>
                        </th>
                    </tr>
                    <tr>
                        <th Align = "LEFT">
                            <xsl:choose>
                                <xsl:when test = "Message/MessageBody/MessageProperties/Instructions/ShipmentComments[@CommentType = 'General']   !=''">
                                    <font face = "Verdana" Size = "1">
                                        <xsl:value-of select = "Message/MessageBody/MessageProperties/Instructions/ShipmentComments[@CommentType = 'General']"/>
                                    </font>
                                </xsl:when>
                                <xsl:otherwise>--</xsl:otherwise>
                            </xsl:choose>
                        </th>
                    </tr>
                </table>
                <p></p>
                <table
                    width = "100%"
                    cellpading = "0"
                    cellspacing = "0">
                    <tr>
                        <th colspan = "5" Align = "LEFT">
                            <font face = "Verdana" Size = "2">BOOKING PARTIES</font>
                        </th>
                    </tr>
                    <tr>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Party</font>
                        </th>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Name</font>
                        </th>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Contact</font>
                        </th>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Contact Information</font>
                        </th>
                    </tr>
                    <xsl:for-each select = "Message/MessageBody/MessageProperties/Parties/PartnerInformation">
                        <tr>
                            <td>
                                <xsl:choose>
                                    <xsl:when test = "@PartnerRole !=''">
                                        <font face = "Verdana" Size = "1">
                                            <xsl:value-of select = "@PartnerRole"/>
                                        </font>
                                    </xsl:when>
                                    <xsl:otherwise>--</xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test = "PartnerName !=''">
                                        <font face = "Verdana" Size = "1">
                                            <xsl:value-of select = "PartnerName"/>
                                        </font>
                                    </xsl:when>
                                    <xsl:otherwise>--</xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <font face = "Verdana" Size = "1"></font>
                                <xsl:choose>
                                    <xsl:when test = "ContactInformation/ContactName   !=''">
                                        <font face = "Verdana" Size = "1">
                                            <xsl:value-of select = "ContactInformation/ContactName"/>
                                        </font>
                                    </xsl:when>
                                    <xsl:otherwise>--</xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <xsl:choose>
                                    <xsl:when test = "ContactInformation/CommunicationValue   !=''">
                                        <font face = "Verdana" Size = "1">
                                            <xsl:value-of select = "ContactInformation/CommunicationValue"/>
                                        </font>
                                    </xsl:when>
                                    <xsl:otherwise>--</xsl:otherwise>
                                </xsl:choose>
                            </td>
                        </tr>
                    </xsl:for-each>
                </table>
                <p></p>
                <table
                    width = "100%"
                    cellpading = "0"
                    cellspacing = "0">
                    <tr>
                        <th colspan = "5" Align = "LEFT">
                            <font face = "Verdana" Size = "2">NOTIFICATION</font>
                        </th>
                    </tr>
                    <tr>
                        <th Align = "LEFT">
                            <font face = "Verdana" Size = "1">Partner Notification</font>
                        </th>
                    </tr>
                    <tr>
                        <th Align = "LEFT">
                            <xsl:choose>
                                <xsl:when test = "Message/MessageBody/MessageProperties/PushNotificationContactInformation/CommunicationValue[@CommunicationType='Email']   !=''">
                                    <font face = "Verdana" Size = "1">
                                        <xsl:value-of select = "Message/MessageBody/MessageProperties/PushNotificationContactInformation/CommunicationValue[@CommunicationType='Email']"/>
                                    </font>
                                </xsl:when>
                                <xsl:otherwise>--</xsl:otherwise>
                            </xsl:choose>
                        </th>
                    </tr>
                </table>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
