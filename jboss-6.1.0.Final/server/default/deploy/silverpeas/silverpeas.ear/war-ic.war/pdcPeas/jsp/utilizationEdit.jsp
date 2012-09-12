<%--

    Copyright (C) 2000 - 2012 Silverpeas

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    As a special exception to the terms and conditions of version 3.0 of
    the GPL, you may redistribute this Program in connection with Free/Libre
    Open Source Software ("FLOSS") applications as described in Silverpeas's
    FLOSS exception.  You should have received a copy of the text describing
    the FLOSS exception, and it is also available here:
    "http://www.silverpeas.org/legal/licensing"

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ include file="checkPdc.jsp"%>
<%
	Axis axis = (Axis) request.getAttribute("AxisDetail");
	UsedAxis usedAxis = (UsedAxis) request.getAttribute("UsedAxis");
	String error = (String) request.getAttribute("ErrorState");
	String modificationNotAllowed = (String) request.getAttribute("ModificationNotAllowed");

	String baseValue = new Integer(usedAxis.getBaseValue()).toString();
	String usedAxisId = usedAxis.getPK().getId();

	String mandatoryChecked = "";
	String notMandatoryChecked = "";
	if (usedAxis.getMandatory() == 1) {
		mandatoryChecked = "checked";		
	} else {
		notMandatoryChecked = "checked";
	}

	String variantChecked = "";
	String notVariantChecked = "";
	if (usedAxis.getVariant() == 1) {
		variantChecked = "checked";
	} else {
		notVariantChecked = "checked";
	}

	String axisName = axis.getAxisHeader().getName(language);
	ArrayList axisValues = (ArrayList) axis.getValues();
	Value value = null;
	String valueName = "";
	String valueId = "";
	int valueLevel = -1;
	String increment = "";
	String errorMessage = null;

	if (error != null) {
		errorMessage = "<font size=2 color=#FF6600><b>"+resource.getString("pdcPeas.errorMessage")+"</b></font>";
	} else if (modificationNotAllowed != null){
		errorMessage = "<font size=2 color=#FF6600><b>"+resource.getString("pdcPeas.positionExist")+"</b></font>";
	}


%>
<html>
<HEAD>
<TITLE><%=resource.getString("GML.popupTitle")%></TITLE>
<%
   out.println(gef.getLookStyleSheet());
%>
<script type="text/javascript" src="<%=m_context%>/util/javaScript/animation.js"></script>
<script type="text/javascript" src="<%=m_context%>/util/javaScript/checkForm.js"></script>
<script type="text/javascript" src="<%=m_context%>/pdcPeas/jsp/javascript/formUtil.js"></script>
<script language="Javascript">
function sendData() {
	document.axisForm.submit();
}
function goBack(){
	document.goBack.submit();
}
</script>
</HEAD>
<BODY marginheight="5" marginwidth="5" leftmargin="5" topmargin="5" bgcolor="#FFFFFF">
<%	
    browseBar.setDomainName("Plan de classement");
    browseBar.setComponentName("Gestion");
	browseBar.setPath(resource.getString("pdcPeas.axisUse")+" : "+axisName+"");

    out.println(window.printBefore());
    out.println(frame.printBefore());
    out.println(board.printBefore());
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="4">
    <form action="<%=pdcUtilizationContext%>UtilizationUpdateAxis" name="axisForm" method="post">
	<%
	  if (errorMessage != null) {
	%>
		<tr><td colspan="2"><%=errorMessage%></span></td></tr>
	<%
	  }
	%>
		<input type="hidden" name="Id" value="<%=usedAxisId%>">
      <tr> 
        <td class="txtlibform" width="50%" nowrap><%=resource.getString("pdcPeas.baseValue")%>&nbsp;:</td>
        <td width="50%" nowrap>
			<select name="BaseValue">
		<%
			for (int i = 0; i<axisValues.size(); i++) 
			{
				value = (Value) axisValues.get(i);
				valueName = value.getName(language);
				valueId = value.getPK().getId();
				valueLevel = value.getLevelNumber();
				increment = "";
				for (int j = 0; j < valueLevel; j++) 
					increment += "&nbsp;&nbsp;";

				if (baseValue.equals(valueId))
					out.println("<option value="+valueId+" selected>"+increment+valueName+"</option>");
				else
					out.println("<option value="+valueId+">"+increment+valueName+"</option>");
			}
		%>
			</select>
		</td>
      </tr>
      <tr> 
        <td class="txtlibform" nowrap><%=resource.getString("pdcPeas.axisUse2")%>&nbsp;:</td>
        <td nowrap>
          <input type="radio" name="Mandatory" value="1" <%=mandatoryChecked%>><span class="textePetitBold">&nbsp;<%=resource.getString("GML.requiredField")%></span><br>
          <input type="radio" name="Mandatory" value="0" <%=notMandatoryChecked%>><span class="textePetitBold">&nbsp;<%=resource.getString("pdcPeas.optional")%></span></td>
      </tr>
      <% if (isAxisInvarianceUsed) { %>
	  <tr> 
        <td class="txtlibform" nowrap><%=resource.getString("pdcPeas.axisValue")%>&nbsp;:</td>
        <td nowrap>
          <input type="radio" name="Variant" value="1" <%=variantChecked%>><span class="textePetitBold">&nbsp;<%=resource.getString("pdcPeas.variants")%></span><br>
          <input type="radio" name="Variant" value="0" <%=notVariantChecked%>><span class="textePetitBold">&nbsp;<%=resource.getString("pdcPeas.notVariants")%></span></td>
      </tr>		     
      <% } %>
	</form>
  </table>
  <%
  	out.println(board.printAfter());
  
    ButtonPane buttonPane = gef.getButtonPane();
    buttonPane.addButton((Button) gef.getFormButton(resource.getString("GML.validate"), "javascript:sendData()", false));
	buttonPane.addButton((Button) gef.getFormButton(resource.getString("GML.cancel"), "javascript:goBack()", false));
	out.println("<br/><center>"+buttonPane.print()+"</center><br/>");
  
	out.println(frame.printAfter());
	out.println(window.printAfter());
%>
<form name="goBack" action="<%=pdcUtilizationContext%>Main" method="post">
</form>
</BODY>
</HTML>