<%--

    Copyright (C) 2000 - 2011 Silverpeas

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    As a special exception to the terms and conditions of version 3.0 of
    the GPL, you may redistribute this Program in connection with Free/Libre
    Open Source Software ("FLOSS") applications as described in Silverpeas's
    FLOSS exception.  You should have received a copy of the text describing
    the FLOSS exception, and it is also available here:
    "http://repository.silverpeas.com/legal/licensing"

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.util.*"%>

<%@ include file="checkQuestionReply.jsp" %>
<%@ include file="tabManager.jsp.inc" %>
<%
	Question 	question 	= (Question) request.getAttribute("question");
	String		profil		= (String) request.getAttribute("Flag");
	Collection allCategories = (Collection) request.getAttribute("AllCategories");
	
	String categoryId = question.getCategoryId();
	
	String title = Encode.javaStringToHtmlString(question.getTitle());
	String content = Encode.javaStringToHtmlString(question.getContent());
	String date = resource.getOutputDate(question.getCreationDate());
	String id = question.getPK().getId();
	int status = question.getStatus();
	String creator = Encode.javaStringToHtmlString(question.readCreatorName());
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><%=resource.getString("GML.popupTitle")%></title>
<view:looknfeel />
<link rel="stylesheet" type="text/css" href="css/question-reply-css.jsp" />
<script language="JavaScript">
<!--
function isCorrectForm() {
     	var errorMsg = "";
     	var errorNb = 0;
     	
	var title = document.forms[0].title.value;
	var content = document.forms[0].content;
        
	if (isWhitespace(title)) {
           errorMsg+="  - '<%=resource.getString("GML.name")%>' <%=resource.getString("GML.MustBeFilled")%>\n";
           errorNb++; 
        }              
	
  	if (!isValidTextArea(content)) {
  		errorMsg+="  - '<%=resource.getString("GML.description")%>' <%=resource.getString("questionReply.containsTooLargeText")+resource.getString("questionReply.nbMaxTextArea")+resource.getString("questionReply.characters")%>\n";
       	errorNb++; 
	}  	  	
		
     switch(errorNb)
     {
        case 0 :
            result = true;
            break;
        case 1 :
            errorMsg = "<%=resource.getString("GML.ThisFormContains")%> 1 <%=resource.getString("GML.error")%> : \n" + errorMsg;
            window.alert(errorMsg);
            result = false;
            break;
        default :
            errorMsg = "<%=resource.getString("GML.ThisFormContains")%> " + errorNb + " <%=resource.getString("GML.errors")%> :\n" + errorMsg;
            window.alert(errorMsg);
            result = false;
            break;
     }
     return result;	
     
}
function save()
{
	if (isCorrectForm())
		document.forms[0].submit();
}
function cancel(id)
{
	document.QForm.action = "ConsultQuestionQuery";
	document.QForm.questionId.value = id;
	document.QForm.submit();
}
//-->
</script>
</head>
<body id="<%=componentId%>" class="questionReply updateQ" onload="document.forms[0].title.focus();">

<%
	browseBar.setDomainName(spaceLabel);
   	browseBar.setPath("<a href="+routerUrl+"Main></a>" + title);
   	
	out.println(window.printBefore());
	
	boolean pdc = true;
	if (profil.equals("publisher")) {
		pdc = false;
	}
	if (!profil.equals("user")) {
		displayTabs(true, pdc, id, resource, gef, "CreateQQuery", routerUrl, out);
	}
	
	out.println(frame.printBefore());
	out.println(board.printBefore());
%>

<form method="post" name="myForm" action="EffectiveUpdateQ">
<table cellpadding="5" width="100%">
	<!-- Affichage de la liste des cat�gories -->
	<tr>
	  	<td>
	  		<span class="txtlibform"><%= resource.getString("questionReply.category") %> :&nbsp;</span>
	    </td>
	    <td>
			<select name="CategoryId">
			<option value=""></option>
			<%
			if (allCategories != null) {
				String selected = "";
    			Iterator<NodeDetail> it = allCategories.iterator();
    			while (it.hasNext()) {
    				NodeDetail uneCategory = it.next();
    				if (categoryId != null && categoryId.equals(uneCategory.getNodePK().getId()))
    					selected = "selected";
    				%>
    				<option value=<%=uneCategory.getNodePK().getId()%> <%=selected%>><%=uneCategory.getName()%></option>
    				<%
    				selected = "";
		  		}
    		}
			%>
			</select>
		</td>
	</tr>
	<tr> 
		<td class="txtlibform"><%=resource.getString("questionReply.question")%> :</td>
		<td><input type="text" name="title" size="120" maxlength="100" value="<%=title%>" />&nbsp;<img alt="<%=resource.getString("GML.requiredField")%>" src="<%=resource.getIcon("questionReply.mandatory")%>" width="5" height="5" />
		<input type="hidden" name="questionId" value="<%=id%>" /></td>
	</tr>
	<tr valign="top"> 
		<td class="txtlibform"><%=resource.getString("GML.description")%> :</td>
		<td><textarea cols="120" rows="5" name="content"><%=content%></textarea></td>
	</tr>
	<tr> 
		<td class="txtlibform"><%=resource.getString("GML.date")%> :</td>
		<td><%=date%></td>
	</tr>
	<tr> 
		<td class="txtlibform"><%=resource.getString("GML.publisher")%> :</td>
		<td><%=creator%></td>
	</tr>
	<tr>				 
		<td colspan="2"><span class="txt">(<img alt="<%=resource.getString("GML.requiredField")%>" src="<%=resource.getIcon("questionReply.mandatory")%>" width="5" height="5" /> : <%=resource.getString("GML.requiredField")%>)</span></td>
	</tr>
</table>
</form>
<% out.println(board.printAfter()); %>
<br />
<%
    ButtonPane buttonPane = gef.getButtonPane();
    buttonPane.addButton((Button) gef.getFormButton(resource.getString("GML.validate"), "javascript:save();", false));
    buttonPane.addButton((Button) gef.getFormButton(resource.getString("GML.cancel"), "javascript:cancel('"+id+"');", false));
    out.println(buttonPane.print());
	out.println(frame.printAfter());
	out.println(window.printAfter());
%>

<form name="QForm" action="" method="post">
	<input type="hidden" name="questionId" />
</form>

</body>
</html>