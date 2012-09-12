<%--

    Copyright (C) 2000 - 2011 Silverpeas

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    As a special exception to the terms and conditions of version 3.0 of
    the GPL, you may redistribute this Program in connection with Free/Libre
    Open Source Software ("FLOSS") applications as described in Silverpeas's
    FLOSS exception.  You should have recieved a copy of the text describing
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
<%
    response.setHeader("Cache-Control", "no-store"); //HTTP 1.1
    response.setHeader("Pragma", "no-cache"); //HTTP 1.0
    response.setDateHeader("Expires", -1); //prevents caching at the proxy server
%>
<%@ include file="checkForums.jsp"%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib uri="http://www.silverpeas.com/tld/viewGenerator" prefix="view"%>

<fmt:setLocale value="${sessionScope['SilverSessionController'].favoriteLanguage}" />
<view:setBundle basename="com.stratelia.webactiv.forums.multilang.forumsBundle"/>

<%!
public String navigationBar(int forumId, ResourceLocator resource, ForumsSessionController fsc)
    throws ForumsException
{
    String navigation = "";
    if (forumId != 0)
    {
    	navigation = "<a href=\"" + ActionUrl.getUrl("viewForum", -1, forumId) + "\">" +
            fsc.getForumName(forumId) + "</a>";
        int currentId = forumId;
        boolean loop = true;
        while (loop)
        {
            int forumParent = fsc.getForumParentId(currentId);
            if (forumParent == 0)
            {
            	loop = false;
            }
            else
            {
                String parentName = fsc.getForumName(forumParent);
                String line = "<a href=\"" + ActionUrl.getUrl("viewForum", -1, forumParent)
                    + "\">" + parentName + "</a> &gt; ";
                navigation = line + navigation;
                currentId = forumParent;
            }
        }
    }
    return navigation;
}

public void listFolders(JspWriter out, int rootId, int forumId, int parentId, String indent,
    ForumsSessionController fsc)
{
    try
    {
        int[] sonsIds = fsc.getForumSonsIds(rootId);
        Forum sonForum;
        for (int i = 0; i < sonsIds.length; i++)
        {
            int sonId = sonsIds[i];
            if (forumId != sonId)
            {
                sonForum = fsc.getForum(sonId);
                out.print("<option ");
                if (parentId == sonForum.getId())
                {
                	out.println("selected ");
                }
                out.print("value=\"");
                out.print(sonForum.getId());
                out.print("\">");
                out.print(indent + EncodeHelper.javaStringToHtmlString(sonForum.getName()));
                out.println("</option>");
                listFolders(out, sonId, forumId, parentId, indent + "-", fsc);
            }
        }
    }
    catch (IOException ioe)
    {
        SilverTrace.info("forums", "JSPeditForumInfo.listFolders()", "root.EX_NO_MESSAGE", null, ioe);
    }
}
%>
<%
    Collection<NodeDetail> allCategories = fsc.getAllCategories();

    int forumId = getIntParameter(request, "forumId", 0);

    String call = request.getParameter("call");
    String backURL = ActionUrl.getUrl(call, -1, forumId);

    int params = getIntParameter(request, "params");

    int action = getIntParameter(request, "action", 1);

    SilverTrace.debug("forums", "JSPeditForumInfo", "root.MSG_GEN_PARAM_VALUE",
        "isAdmin=" + isAdmin + " ; " + "forumId=" + forumId + " ; " + "call=" + call
        + " ; " + "params=" + params + " ; " + "action=" + action);

    int parentId = 0;
    boolean update = false;
  	if (action == 1) {
  		parentId = params;
      update = false;
    } else if (action == 2) {
  		forumId = params;
      update = true;
    }

    boolean isModerator = (params != 0 && fsc.isModerator(userId, params));

    Forum forum = null;
    String categoryId = null;
    String keywords = null;
    if (update)
    {
        forum = fsc.getForum(forumId);
        parentId = forum.getParentId();
        categoryId = forum.getCategory();
        keywords = fsc.getForumKeywords(forumId);
    }
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">  
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
<link type="text/css" href="<%=context%>/util/styleSheets/fieldset.css" rel="stylesheet" />
<view:looknfeel/>
<script type="text/javascript" src="<%=context%>/util/javaScript/checkForm.js"></script>
<script type="text/javascript" src="<%=context%>/forums/jsp/javaScript/forums.js"></script>
<script type="text/javascript" src="<%=context%>/util/javaScript/animation.js"></script>
<script type="text/javascript">
<%
    if (isAdmin || isModerator)
    {
%>
function submitForm()
{
  nbr = document.forumsForm.moderators.length;
  var j;
  for (j = 0; j < nbr; j++) {
    document.forumsForm.moderators[j].selected = true;
  }

  if (isCorrectForm()) {
    <view:pdcPositions setIn="document.forumsForm.Positions.value"/>;          
    document.forumsForm.submit();
  }
}

function isCorrectForm() {

  var errorMsg = "";
  var errorNb = 0;

  if (isWhitespace(stripInitialWhitespace(document.forumsForm.forumName.value))) {
    errorMsg+="  - <fmt:message key="GML.theField"/> '<fmt:message key="GML.name"/>' <fmt:message key="GML.MustBeFilled"/>\n";
    errorNb++;
  }
  
  if (!isValidTextArea(document.forumsForm.forumDescription)) {
    errorMsg+="  - <fmt:message key="GML.theField"/> '<fmt:message key="forumDescription"/>' <fmt:message key="ContainsTooLargeText"/> <%=DBUtil.getTextAreaLength()%> <fmt:message key="Characters"/>\n";
    errorNb++;
  }
  
  <view:pdcValidateClassification errorCounter="errorNb" errorMessager="errorMsg"/>

  switch(errorNb) {
  case 0 :
      result = true;
      break;
  case 1 :
      errorMsg = "<fmt:message key="GML.ThisFormContains"/> 1 <fmt:message key="GML.error"/> :\n" + errorMsg;
      window.alert(errorMsg);
      result = false;
      break;
  default :
      errorMsg = "<fmt:message key="GML.ThisFormContains"/> " + errorNb + " <fmt:message key="GML.errors"/> :\n" + errorMsg;
      window.alert(errorMsg);
      result = false;
      break;
  }

  
  return result;
}

function moveUsers(button)
{
    var z = 0;
    var indexArray = new Array();
    if (button == ">")
    {
        var source = document.forumsForm.availableUsers;
        var target = document.forumsForm.moderators;
    }
    else
    {
        var target = document.forumsForm.availableUsers;
        var source = document.forumsForm.moderators;
    }
    var i;
    for (i = 0; i < source.length; i++)
    {
        if (source.options[i].selected)
        {
            var selectedText = source.options[i].text;
            var selectedValue = source.options[i].value;
            target.options[target.length] = new Option(selectedText, selectedValue);
            indexArray[z] = i;
            z++;
        }
    }
    for (i = source.length - 1; i >= 0; i--)
    {
        source.options[indexArray[i]] = null;
    }
}

function moveAllUsers()
{
    var target = document.forumsForm.availableUsers;
    var source = document.forumsForm.moderators;
    var i;
    for (i = 0; i < source.length; i++)
    {
        var selectedText = source.options[i].text;
        var selectedValue = source.options[i].value;
        target.options[target.length] = new Option(selectedText, selectedValue);
    }
    for (i = source.length - 1; i >= 0; i--)
    {
        source.options[i] = null;
    }
}

function removeAllUsers()
{
    var source = document.forumsForm.availableUsers;
    var target = document.forumsForm.moderators;
    var i;
    for (i = 0; i < source.length; i++)
    {
        var selectedText = source.options[i].text;
        var selectedValue = source.options[i].value;
        target.options[target.length] = new Option(selectedText, selectedValue);
    }
    for (i = source.length - 1; i >= 0; i--)
    {
        source.options[i] = null;
    }
}
<%
    }
%>
    </script>
</head>

<body id="creation-page" class="forum" <%addBodyOnload(out, fsc, "document.forumsForm.forumName.focus();");%>>
<%
    Window window = graphicFactory.getWindow();

    BrowseBar browseBar = window.getBrowseBar();
    browseBar.setDomainName(fsc.getSpaceLabel());
    browseBar.setComponentName(fsc.getComponentLabel(), ActionUrl.getUrl("main"));
    browseBar.setPath(navigationBar(forumId, resource, fsc));
    browseBar.setExtraInformation(resource.getString("creatnewForum"));

    if (!isReader)
    {
        OperationPane operationPane = window.getOperationPane();
        operationPane.addOperation(context + "/util/icons/forums_mailtoAdmin.gif",
            resource.getString("mailAdmin"),
            "javascript:notifyPopup2('" + context + "','" + fsc.getComponentId() + "','"
                + fsc.getAdminIds() + "','');");
    }

    out.println(window.printBefore());

    Frame frame = graphicFactory.getFrame();

    out.println(frame.printBefore());
    if (isAdmin || isModerator)
    {
        String formAction = ActionUrl.getUrl("main", (update ? 7 : 3), (forumId > 0 ? forumId : -1));
%>

  <form name="forumsForm" action="<%=formAction%>" method="post">
    <input type="hidden" name="Positions" />

<fieldset id="infoFieldset" class="skinFieldset">
  <legend><fmt:message key="forums.header.fieldset.info" /></legend>
  
  <!-- SAISIE DU FORUM -->
  <div class="fields">
    <!-- Forum name -->
    <div class="field" id="nameArea">
      <label class="txtlibform" for="forumName"><fmt:message key="forumName" /> :&nbsp;</label>
      <div class="champs">
        <input type="text" name="forumName" size="50" maxlength="<%=DBUtil.getTextFieldLength()%>" <%if (update) {%>value="<%=EncodeHelper.javaStringToHtmlString(forum.getName())%>"<%}%> />&nbsp;<img src="<%=context%>/util/icons/mandatoryField.gif" width="5" height="5"/>
      </div>
    </div>
    <!-- Display category list -->
    <div class="field" id="categoryArea">
      <label class="txtlibform" for="CategoryId"><fmt:message key="forums.category" /> :&nbsp;</label>
      <div class="champs">
        <select name="CategoryId">
            <option value=""></option><%

      if (allCategories != null)
      {
          Iterator<NodeDetail> it = allCategories.iterator();
          NodeDetail currentCategory;
          String currentCategoryId;
          String selected;
          while (it.hasNext())
          {
              currentCategory = (NodeDetail) it.next();
              currentCategoryId = currentCategory.getNodePK().getId();
              selected = ((categoryId != null && categoryId.equals(currentCategoryId))
                  ? "selected" : "");
%>
            <option value=<%=currentCategoryId%> <%=selected%>><%=currentCategory.getName()%></option>
<%
          }
      }
%>
          </select>
      </div>
    </div>

<%
        if (fsc.isForumInsideForum()) {
%>
    <!-- Forum folder inside  -->
    <div class="field" id="folderArea">
      <label class="txtlibform" for="forumFolder"><fmt:message key="forumFolder" /> :&nbsp;</label>
      <div class="champs">
        <span class="selectNS">
          <select name="forumFolder">
            <option <%if (parentId == 0) {%>selected <%}%> value="0"><%=resource.getString("racine")%></option><%

            listFolders(out, 0, forumId, parentId, "", fsc);
%>
          </select>
        </span>
        &nbsp;<img src="<%=context%>/util/icons/mandatoryField.gif" width="5" height="5"/>
      </div>
    </div>
<%
        } else {
%>
      <input type="hidden" name="forumFolder" value="0" />
<%     } %>

    <!-- Forum description  -->
    <div class="field" id="descriptionArea">
      <label class="txtlibform" for="forumDescription"><fmt:message key="forumDescription" /> :&nbsp;</label>
      <div class="champs">
        <textarea name="forumDescription" cols="49" rows="6"><%if (update) {%><%=forum.getDescription()%><%}%></textarea>
      </div>
    </div>
    <!-- Forum keywords  -->
    <div class="field" id="keywordsArea">
      <label class="txtlibform" for="forumKeywords"><fmt:message key="forumKeywords" /> :&nbsp;</label>
      <div class="champs">
        <input type="text" name="forumKeywords" size="50" <%if (update) {%>value="<%=keywords%>"<%}%>/>
      </div>
    </div>
  </div>
</fieldset>
<% if (update) { %>
    <input type="hidden" name="forumId" value="<%=forumId%>"/>
<% } %>
        
<fieldset id="moderatorsFieldset" class="skinFieldset">
  <legend><fmt:message key="forums.header.fieldset.moderation" /></legend>
  <table width="98%" cellpadding="0" cellspacing="0" border="0">
      <tr>
          <td nowrap="nowrap" align="right"><span class="txtlibform"><fmt:message key="availableUsers" /> : </span>&nbsp;</td>
          <td nowrap="nowrap" width="10%">&nbsp;</td>
          <td nowrap="nowrap" align="left">&nbsp;<span class="txtlibform"><fmt:message key="moderators" /> : </span></td>
      </tr>
      <tr>
          <td nowrap align="right" valign="middle"><span class="selectNS">
              <select name="availableUsers" multiple size="7"><%

        UserDetail[] userDetails = fsc.listUsers();
        UserDetail userDetail;
        for (int i = 0; i < userDetails.length; i++)
        {
          userDetail = userDetails[i];
            if (params == 0) { %>
                <option value="<%=userDetail.getId()%>"><%=userDetail.getFirstName()%> <%=userDetail.getLastName()%></option>
<%          } else if (!fsc.isModerator(userDetail.getId(), params)) { %>
                <option value="<%=userDetail.getId()%>"><%=userDetail.getLastName()%> <%=userDetail.getFirstName()%></option>
<%
            }
        }
%>
              </select></span>&nbsp;&nbsp;</td>
            <td nowrap align="center" valign="middle">
                <center>
                    <table border="0" cellpadding="0" cellspacing="0" width="37">
                        <tr>
                            <td class="intfdcolor" width="37"><a href="javascript:moveUsers('>');"><img src="icons/bt_fleche-d.gif" width="37" height="24" border="0"/></a><br/>
                            <a href="javascript:moveUsers('<');"><img src="icons/bt_fleche-g.gif" width="37" height="24" border="0"/></a><br/>
                            <a href="javascript:removeAllUsers();"><img src="icons/bt_db-fleche-d.gif" width="37" height="24" border="0"/></a><br/>
                            <a href="javascript:moveAllUsers();"><img src="icons/bt_db-fleche-g.gif" width="37" height="24" border="0"/></a></td>
                        </tr>
                    </table>
                </center>
            </td>
            <td valign="middle" align="left">&nbsp;&nbsp;<span class="selectNS">
                <select name="moderators" multiple size="7"><%
    if (params != 0)
    {
      for (int i = 0; i < userDetails.length; i++)
        {
        userDetail = userDetails[i];
            if (fsc.isModerator(userDetail.getId(), params)) {
%>
                        <option value="<%=userDetail.getId()%>"><%=userDetail.getFirstName()%> <%=userDetail.getLastName()%></option>
<%
            }
        }
    }
%>
                </select></span></td>
        </tr>
    </table>
</fieldset>

<% if (update) { %>
  <view:pdcClassification componentId="<%= fsc.getComponentId() %>" contentId="<%=Integer.toString(forumId)%>" editable="true" />
<% } else { %>
  <view:pdcNewContentClassification componentId="<%=fsc.getComponentId()%>" />
<% } %>

	<div class="legend">
		<fmt:message key="reqchamps" /> : <img src="<%=context%>/util/icons/mandatoryField.gif" width="5" height="5" />
	</div>
                  </form>
<%
    }

    ButtonPane buttonPane = graphicFactory.getButtonPane();
    buttonPane.addButton(graphicFactory.getFormButton(resource.getString("valider"), "javascript:submitForm();", false));
    buttonPane.addButton(graphicFactory.getFormButton(resource.getString("annuler"), backURL, false));
    buttonPane.setHorizontalPosition();
    out.println(buttonPane.print());
    out.println(frame.printAfter());
    out.println(window.printAfter());
%>
</body>
</html>