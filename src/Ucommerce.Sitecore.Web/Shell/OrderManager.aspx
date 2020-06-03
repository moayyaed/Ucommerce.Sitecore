﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="OrderManager.aspx.cs" Inherits="Ucommerce.Sitecore.Web.Shell.OrderManager" MasterPageFile="Masterpages/MasterPageShell.Master"%>

<asp:Content runat="server" ContentPlaceHolderID="ContentPlacerHolder">
	<ucommerce-shell content-picker-type="OrdersApp" tree-indetion-size="31" fixed-left-size="300px" disable-resize="true" start-page="../Orders/OrdersStartPage.aspx?IsSpeak=true" stylesheet="<%= string.Equals(Request.QueryString["IsSpeak"], bool.TrueString, StringComparison.OrdinalIgnoreCase) ? "/sitecore modules/Shell/ucommerce/css/Speak/ucommerce-speak.css" : string.Empty %>" script="<%= string.Equals(Request.QueryString["IsSpeak"], bool.TrueString, StringComparison.OrdinalIgnoreCase) ? "/sitecore modules/Shell/ucommerce/scripts/speak.js" : string.Empty %>"></ucommerce-shell>    
</asp:Content>