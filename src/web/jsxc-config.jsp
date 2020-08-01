<!--
  - Copyright (C) 2017 Ignite Realtime Foundation. All rights reserved.
  -
  - Licensed under the Apache License, Version 2.0 (the "License");
  - you may not use this file except in compliance with the License.
  - You may obtain a copy of the License at
  -
  - http://www.apache.org/licenses/LICENSE-2.0
  -
  - Unless required by applicable law or agreed to in writing, software
  - distributed under the License is distributed on an "AS IS" BASIS,
  - WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  - See the License for the specific language governing permissions and
  - limitations under the License.
-->
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page errorPage="error.jsp" %>
<%@ page import="org.igniterealtime.openfire.plugin.jsxc.JSXCPlugin" %>
<%@ page import="org.jivesoftware.openfire.XMPPServer" %>
<%@ page import="org.jivesoftware.openfire.http.HttpBindManager" %>
<%@ page import="org.jivesoftware.util.CookieUtils" %>
<%@ page import="org.jivesoftware.util.JiveGlobals" %>
<%@ page import="org.jivesoftware.util.ParamUtils" %>
<%@ page import="org.jivesoftware.util.StringUtils" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.igniterealtime.openfire.plugin.jsxc.Language" %>
<%@ page import="org.igniterealtime.openfire.plugin.jsxc.OptionsServlet" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:useBean id="webManager" class="org.jivesoftware.util.WebManager"  />
<% webManager.init(request, response, session, application, out ); %>
<%
    String update = request.getParameter("update");
    String success = request.getParameter("success");
    String error = null;

    final Cookie csrfCookie = CookieUtils.getCookie( request, "csrf");
    String csrfParam = ParamUtils.getParameter( request, "csrf");

    if (update != null ) {
        if (csrfCookie == null || csrfParam == null || !csrfCookie.getValue().equals(csrfParam)) {
            update = null;
            error = "csrf";
        }
    }
    csrfParam = StringUtils.randomString( 15 );
    CookieUtils.setCookie(request, response, "csrf", csrfParam, -1);
    pageContext.setAttribute("csrf", csrfParam);

    HttpBindManager httpBindManager = HttpBindManager.getInstance();

    if ( error == null && update != null )
    {
        if ( "general".equals( update ) )
        {
            final String domain = ParamUtils.getParameter( request, "domain" );
            OptionsServlet.DOMAIN.setValue( domain == null ? null : URLEncoder.encode( domain, "UTF-8" ));
            final String appName = ParamUtils.getParameter( request, "app_name" );
            OptionsServlet.APP_NAME.setValue( appName == null ? null : URLEncoder.encode( appName, "UTF-8" ));
            final String rosterVisibility = ParamUtils.getParameter( request, "roster_visibility" );
            OptionsServlet.ROSTER_VISIBILITY.setValue(OptionsServlet.RosterVisibility.valueOf(rosterVisibility));
            final int hideOfflineContacts = ParamUtils.getIntParameter( request, "hide_offline_contacts", OptionsServlet.HIDE_OFFLINE_CONTACTS.getDefaultValue());
            OptionsServlet.HIDE_OFFLINE_CONTACTS.setValue(hideOfflineContacts);
            final String onlineHelp = ParamUtils.getParameter( request, "online_help" );
            OptionsServlet.ONLINE_HELP.setValue( onlineHelp == null || onlineHelp.isEmpty() ? null : URLEncoder.encode( onlineHelp, "UTF-8" ));
            final String storage = ParamUtils.getParameter( request, "storage" );
            OptionsServlet.STORAGE.setValue(OptionsServlet.Storage.valueOf(storage));
            response.sendRedirect("jsxc-config.jsp?success=update");
            return;
        }

        if ( "rtc".equals( update ) )
        {
            final long ttl = ParamUtils.getLongParameter( request, "ttl", OptionsServlet.RTC_PEER_CONFIG_TTL.getDefaultValue() );
            OptionsServlet.RTC_PEER_CONFIG_TTL.setValue(ttl);
            final String ice_servers = ParamUtils.getParameter( request, "ice_servers" );
            final List<String> servers = new ArrayList<>();
            if ( ice_servers != null ) {
                final String[] split = ice_servers.trim().split("\\r?\\n");
                for ( final String s : split ) {
                    if (!s.trim().isEmpty()) {
                        servers.add(s.trim());
                    }
                }
            }
            OptionsServlet.RTC_PEER_CONFIG_ICE_SERVERS.setValue(servers);
            response.sendRedirect("jsxc-config.jsp?success=update");
            return;
        }

        if ( "language".equals( update ) )
        {
            final int autoLang = ParamUtils.getIntParameter( request, "auto_lang", OptionsServlet.AUTO_LANG.getDefaultValue());
            OptionsServlet.AUTO_LANG.setValue(autoLang);

            if ( "NO_LANG".equals( ParamUtils.getParameter( request, "language" ) ) )
            {
                JiveGlobals.deleteProperty( "jsxc.config.language" );
            }
            else if ( ParamUtils.getParameter( request, "language" ) != null )
            {
                JiveGlobals.setProperty( "jsxc.config.language", URLEncoder.encode( ParamUtils.getParameter( request, "language" ) , "UTF-8" ) );
            }

            response.sendRedirect("jsxc-config.jsp?success=update");
            return;
        }

        // Should not happen. Indicates that a form wasn't processed above.
        response.sendRedirect("jsxc-config.jsp?noupdate");
        return;
    }

    // Read all updated values from the properties.
    //final String currentLoglevel= JiveGlobals.getProperty( "jsxc.config.loglevel", "info" );
%>
<html>
<head>
    <title><fmt:message key="config.page.title"/></title>
    <meta name="pageID" content="jsxc-config"/>
</head>
<body>

<% if ( !httpBindManager.isHttpBindEnabled() ) { %>

<div class="jive-warning">
    <table cellpadding="0" cellspacing="0" border="0">
        <tbody>
        <tr><td class="jive-icon"><img src="images/warning-16x16.gif" width="16" height="16" border="0" alt=""></td>
            <td class="jive-icon-label">
                <fmt:message key="warning.httpbinding.disabled">
                    <fmt:param value="<a href=\"../../http-bind.jsp\">"/>
                    <fmt:param value="</a>"/>
                </fmt:message>
            </td></tr>
        </tbody>
    </table>
</div><br>

<%  } %>

<% if (error != null) { %>

<div class="jive-error">
    <table cellpadding="0" cellspacing="0" border="0">
        <tbody>
        <tr><td class="jive-icon"><img src="images/error-16x16.gif" width="16" height="16" border="0" alt=""></td>
            <td class="jive-icon-label">
                <% if ( "csrf".equalsIgnoreCase( error )  ) { %>
                <fmt:message key="global.csrf.failed" />
                <% } else { %>
                <fmt:message key="admin.error" />: <c:out value="error"></c:out>
                <% } %>
            </td></tr>
        </tbody>
    </table>
</div><br>

<%  } %>


<%  if (success != null) { %>

<div class="jive-success">
    <table cellpadding="0" cellspacing="0" border="0">
        <tbody>
        <tr><td class="jive-icon"><img src="images/success-16x16.gif" width="16" height="16" border="0" alt=""></td>
            <td class="jive-icon-label">
                <fmt:message key="properties.save.success" />
            </td></tr>
        </tbody>
    </table>
</div><br>

<%  } %>

<p>
    <fmt:message key="config.page.description">
        <fmt:param value=""/>
    </fmt:message>
    <% if ( httpBindManager.isHttpBindActive() ) {
        final String unsecuredAddress = "http://" + XMPPServer.getInstance().getServerInfo().getHostname() + ":" + httpBindManager.getHttpBindUnsecurePort() + "/jsxc/";
    %>
        <fmt:message key="config.page.link.unsecure">
            <fmt:param value="<%=unsecuredAddress%>"/>
        </fmt:message>
    <% } %>
    <% if ( httpBindManager.isHttpsBindActive() ) {
        final String securedAddress = "https://" + XMPPServer.getInstance().getServerInfo().getHostname() + ":" + httpBindManager.getHttpBindSecurePort() + "/jsxc/";
    %>
        <fmt:message key="config.page.link.secure">
            <fmt:param value="<%=securedAddress%>"/>
        </fmt:message>
    <% } %>
</p>

<br>

<div class="jive-contentBoxHeader"><fmt:message key="config.page.general.header" /></div>
<div class="jive-contentBox">

    <p><fmt:message key="config.page.general.description" /></p>

    <form action="jsxc-config.jsp">
        <input type="hidden" name="csrf" value="${csrf}"/>
        <input type="hidden" name="update" value="general"/>

        <table cellpadding="3" cellspacing="0" border="0">
            <tbody>
            <tr valign="top">
                <td colspan="2" style="padding-top: 1em;">
                    <fmt:message key="config.page.domain.description"/>
                </td>
            </tr>
            <tr valign="top">
                <td width="1%" nowrap>
                    <label for="domain"><fmt:message key="config.page.domain.label" /></label>
                </td>
                <td width="99%">
                    <input type="text" name="domain" id="domain" size="30" value="<%=OptionsServlet.DOMAIN.getValue()%>">
                </td>
            </tr>

            <tr valign="top">
                <td colspan="2" style="padding-top: 1em;">
                    <fmt:message key="config.page.app_name.description"/>
                </td>
            </tr>
            <tr valign="top">
                <td width="1%" nowrap>
                    <label for="app_name"><fmt:message key="config.page.app_name.label" /></label>
                </td>
                <td width="99%">
                    <input type="text" name="app_name" id="app_name" size="30" value="<%=OptionsServlet.APP_NAME.getValue()%>">
                </td>
            </tr>

            <tr valign="top">
                <td colspan="2" style="padding-top: 1em;">
                    <fmt:message key="config.page.roster_visibility.description"/>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2">
                    <input type="radio" name="roster_visibility" value="<%=OptionsServlet.RosterVisibility.implementationDefault%>" id="rv<%=OptionsServlet.RosterVisibility.implementationDefault%>" <%= (OptionsServlet.RosterVisibility.implementationDefault == OptionsServlet.ROSTER_VISIBILITY.getValue() ? "checked" : "") %>>
                    <label for="rv<%=OptionsServlet.RosterVisibility.implementationDefault%>">
                        <fmt:message key="config.page.roster_visibility.label_default" />
                    </label>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2">
                    <input type="radio" name="roster_visibility" value="<%=OptionsServlet.RosterVisibility.shown%>" id="rv<%=OptionsServlet.RosterVisibility.shown%>" <%= (OptionsServlet.RosterVisibility.shown == OptionsServlet.ROSTER_VISIBILITY.getValue() ? "checked" : "") %>>
                    <label for="rv<%=OptionsServlet.RosterVisibility.shown%>">
                        <fmt:message key="config.page.roster_visibility.label_shown" />
                    </label>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2">
                    <input type="radio" name="roster_visibility" value="<%=OptionsServlet.RosterVisibility.hidden%>" id="rv<%=OptionsServlet.RosterVisibility.hidden%>" <%= (OptionsServlet.RosterVisibility.hidden == OptionsServlet.ROSTER_VISIBILITY.getValue() ? "checked" : "") %>>
                    <label for="rv<%=OptionsServlet.RosterVisibility.hidden%>">
                        <fmt:message key="config.page.roster_visibility.label_hidden" />
                    </label>
                </td>
            </tr>

            <tr valign="top">
                <td colspan="2" style="padding-top: 1em;">
                    <fmt:message key="config.page.hide_offline_contacts.description"/>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2">
                    <input type="radio" name="hide_offline_contacts" value="-1" id="hocd" <%= (-1 == OptionsServlet.HIDE_OFFLINE_CONTACTS.getValue() ? "checked" : "") %>>
                    <label for="hocd">
                        <fmt:message key="config.page.hide_offline_contacts.label_default" />
                    </label>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2">
                    <input type="radio" name="hide_offline_contacts" value="0" id="hoc0" <%= (0 == OptionsServlet.HIDE_OFFLINE_CONTACTS.getValue() ? "checked" : "") %>>
                    <label for="hoc0">
                        <fmt:message key="config.page.hide_offline_contacts.label_false" />
                    </label>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2">
                    <input type="radio" name="hide_offline_contacts" value="1" id="hoc1" <%= (1 == OptionsServlet.HIDE_OFFLINE_CONTACTS.getValue() ? "checked" : "") %>>
                    <label for="hoc1">
                        <fmt:message key="config.page.hide_offline_contacts.label_true" />
                    </label>
                </td>
            </tr>

            <tr valign="top">
                <td colspan="2" style="padding-top: 1em;">
                    <fmt:message key="config.page.online_help.description"/>
                </td>
            </tr>
            <tr valign="top">
                <td width="1%" nowrap>
                    <label for="online_help"><fmt:message key="config.page.online_help.label" /></label>
                </td>
                <td width="99%">
                    <input type="text" name="online_help" id="online_help" size="50" value="<%=OptionsServlet.ONLINE_HELP.getValue() == null ? "" : OptionsServlet.ONLINE_HELP.getValue()%>">
                    <fmt:message key="config.page.leave_empty_for_default" />
                </td>
            </tr>

            <tr valign="top">
                <td colspan="2" style="padding-top: 1em;">
                    <fmt:message key="config.page.storage.description"/>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2">
                    <input type="radio" name="storage" value="<%=OptionsServlet.Storage.implementationDefault%>" id="st<%=OptionsServlet.Storage.implementationDefault%>" <%= (OptionsServlet.Storage.implementationDefault == OptionsServlet.STORAGE.getValue() ? "checked" : "") %>>
                    <label for="st<%=OptionsServlet.Storage.implementationDefault%>">
                        <fmt:message key="config.page.storage.label_default" />
                    </label>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2">
                    <input type="radio" name="storage" value="<%=OptionsServlet.Storage.localStorage%>" id="st<%=OptionsServlet.Storage.localStorage%>" <%= (OptionsServlet.Storage.localStorage == OptionsServlet.STORAGE.getValue() ? "checked" : "") %>>
                    <label for="st<%=OptionsServlet.Storage.localStorage%>">
                        <fmt:message key="config.page.storage.label_local_storage" />
                    </label>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2">
                    <input type="radio" name="storage" value="<%=OptionsServlet.Storage.sessionStorage%>" id="st<%=OptionsServlet.Storage.sessionStorage%>" <%= (OptionsServlet.Storage.sessionStorage == OptionsServlet.STORAGE.getValue() ? "checked" : "") %>>
                    <label for="st<%=OptionsServlet.Storage.sessionStorage%>">
                        <fmt:message key="config.page.storage.label_session_storage" />
                    </label>
                </td>
            </tr>

            </tbody>
        </table>

        <br>

        <input type="submit" value="<fmt:message key="global.save_settings" />">

    </form>

</div>


<div class="jive-contentBoxHeader"><fmt:message key="config.page.rtc.header" /></div>
<div class="jive-contentBox">
    <p><fmt:message key="config.page.rtc.description" /></p>

    <form action="jsxc-config.jsp">
        <input type="hidden" name="csrf" value="${csrf}">
        <input type="hidden" name="update" value="rtc"/>

        <table cellpadding="3" cellspacing="0" border="0">
            <tbody>
            <tr valign="top">
                <td colspan="2" style="padding-top: 1em;">
                    <fmt:message key="config.page.ttl.description"/>
                </td>
            </tr>
            <tr valign="top">
                <td width="1%" nowrap>
                    <label for="ttl"><fmt:message key="config.page.ttl.label" /></label>
                </td>
                <td width="99%">
                    <input type="number" name="ttl" id="ttl" value="<%=OptionsServlet.RTC_PEER_CONFIG_TTL.getValue() < 0 ? "" : OptionsServlet.RTC_PEER_CONFIG_TTL.getValue()%>">
                    <fmt:message key="config.page.leave_empty_for_default" />
                </td>
            </tr>

            <tr valign="top">
                <td colspan="2" style="padding-top: 1em;">
                    <fmt:message key="config.page.ice_servers.description">
                        <fmt:param value="http://www.w3.org/TR/webrtc/#idl-def-RTCIceServer"/>
                    </fmt:message>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2">
                    <%
                        final List<String> servers = OptionsServlet.RTC_PEER_CONFIG_ICE_SERVERS.getValue();
                        String content = "";
                        if ( servers != null ) {
                            for ( final String server : servers ) {
                                content += URLEncoder.encode(server.trim(), "UTF-8") + '\n';
                            }
                        }
                    %>
                    <textarea cols="60" rows="4" name="ice_servers" id="ice_servers"><%= content %></textarea><br/>
                    <fmt:message key="config.page.one_per_line" />
                    <fmt:message key="config.page.leave_empty_for_default" />
                </td>
            </tr>
            </tbody>
        </table>

        <br>

        <input type="submit" value="<fmt:message key="global.save_settings" />">

    </form>

</div>


<div class="jive-contentBoxHeader"><fmt:message key="config.page.language.header" /></div>
<div class="jive-contentBox">

    <form action="jsxc-config.jsp">
        <input type="hidden" name="csrf" value="${csrf}">
        <input type="hidden" name="update" value="language"/>

        <table cellpadding="3" cellspacing="0" border="0">
            <tbody>
            <tr valign="top">
                <td colspan="2" style="padding-top: 1em;">
                    <fmt:message key="config.page.auto_lang.description"/>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2">
                    <input type="radio" name="auto_lang" value="-1" id="ald" <%= (-1 == OptionsServlet.AUTO_LANG.getValue() ? "checked" : "") %>>
                    <label for="ald">
                        <fmt:message key="config.page.auto_lang.label_default" />
                    </label>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2">
                    <input type="radio" name="auto_lang" value="0" id="al0" <%= (0 == OptionsServlet.AUTO_LANG.getValue() ? "checked" : "") %>>
                    <label for="al0">
                        <fmt:message key="config.page.auto_lang.label_false" />
                    </label>
                </td>
            </tr>
            <tr valign="top">
                <td colspan="2">
                    <input type="radio" name="auto_lang" value="1" id="al1" <%= (1 == OptionsServlet.AUTO_LANG.getValue() ? "checked" : "") %>>
                    <label for="al1">
                        <fmt:message key="config.page.auto_lang.label_true" />
                    </label>
                </td>
            </tr>

            <%
                final Language currentLanguage = JSXCPlugin.getLanguage();
            %>
            <tr valign="top">
                <td colspan="2" style="padding-top: 1em;">
                    <fmt:message key="config.page.language.description"/>
                </td>
            </tr>
            <tr valign="top">
                <td width="1%" nowrap style="padding-top: 1em;">
                    <input type="radio" name="language" value="NO_LANG" id="NO_LANG" <%= (currentLanguage == null ? "checked" : "") %>>
                </td>
                <td width="99%" style="padding-top: 1em;">
                    <label for="NO_LANG">
                        <fmt:message key="config.page.language.no_lang" />
                    </label>
                </td>
            </tr>
            <%
                for ( final Language language : Language.values() )
                {
            %>
            <tr valign="top">
                <td width="1%" nowrap>
                    <input type="radio" name="language" value="<%=language.getCode()%>" id="<%=language.getCode()%>" <%= (currentLanguage == language ? "checked" : "") %>>
                </td>
                <td width="99%">
                    <label for="<%=language.getCode()%>">
                        <%= language %>
                    </label>
                </td>
            </tr>
            <%
                }
            %>
            </tbody>
        </table>

        <br>

        <input type="submit" value="<fmt:message key="global.save_settings" />">

    </form>

</div>

</body>
</html>
