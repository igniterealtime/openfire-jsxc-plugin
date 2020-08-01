/*
 * Copyright (C) 2017 Ignite Realtime Foundation. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.igniterealtime.openfire.plugin.jsxc;

import org.jivesoftware.openfire.XMPPServer;
import org.jivesoftware.util.JiveGlobals;
import org.jivesoftware.util.SystemProperty;
import org.json.JSONArray;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.Writer;
import java.util.Collections;
import java.util.List;

/**
 * Generates a JSON object that contains configuration for the JSXC web application.
 *
 * @author Guus der Kinderen, guus.der.kinderen@gmail.com
 */
public class OptionsServlet extends HttpServlet
{
    private static final Logger Log = LoggerFactory.getLogger( OptionsServlet.class );

    public static final SystemProperty<String> DOMAIN = SystemProperty.Builder.ofType( String.class )
        .setKey( "jsxc.config.domain" )
        .setDefaultValue( XMPPServer.getInstance().getServerInfo().getXMPPDomain() )
        .setDynamic( true )
        .setPlugin( "JSXC" )
        .build();

    public static final SystemProperty<String> APP_NAME = SystemProperty.Builder.ofType( String.class )
        .setKey( "jsxc.config.app_name" )
        .setDefaultValue( "Openfire" )
        .setDynamic( true )
        .setPlugin( "JSXC" )
        .build();

    public static final SystemProperty<Integer> AUTO_LANG = SystemProperty.Builder.ofType( Integer.class )
        .setKey( "jsxc.config.auto_lang" )
        .setDefaultValue( -1 ) // Faking a nullable boolean: -1 used for null, 0 for false, 1 for true.
        .setDynamic( true )
        .setPlugin( "JSXC" )
        .build();

    public static final SystemProperty<String> ROSTER_APPEND = SystemProperty.Builder.ofType( String.class )
        .setKey( "jsxc.config.roster_append" )
        .setDynamic( true )
        .setPlugin( "JSXC" )
        .build();

    public enum RosterVisibility {
        implementationDefault,
        shown,
        hidden
    }

    public static final SystemProperty<RosterVisibility> ROSTER_VISIBILITY = SystemProperty.Builder.ofType( RosterVisibility.class )
        .setKey( "jsxc.config.roster_visibility" )
        .setDefaultValue( RosterVisibility.implementationDefault )
        .setDynamic( true )
        .setPlugin( "JSXC" )
        .build();

    public static final SystemProperty<Integer> HIDE_OFFLINE_CONTACTS = SystemProperty.Builder.ofType( Integer.class )
        .setKey( "jsxc.config.hide_offline_contacts" )
        .setDefaultValue( -1 ) // Faking a nullable boolean: -1 used for null, 0 for false, 1 for true.
        .setDynamic( true )
        .setPlugin( "JSXC" )
        .build();

    public static final SystemProperty<Long> RTC_PEER_CONFIG_TTL = SystemProperty.Builder.ofType( Long.class )
        .setKey( "jsxc.config.rtc_peer_config.ttl" )
        .setDefaultValue( -1L )
        .setDynamic( true )
        .setPlugin( "JSXC" )
        .build();

    public static final SystemProperty<List<String>> RTC_PEER_CONFIG_ICE_SERVERS = SystemProperty.Builder.ofType( List.class )
        .setKey( "jsxc.config.rtc_peer_config.ice_servers" )
        .setDefaultValue( Collections.emptyList() )
        .setDynamic( true )
        .setPlugin( "JSXC" )
        .buildList( String.class );

    public static final SystemProperty<String> ONLINE_HELP = SystemProperty.Builder.ofType( String.class )
        .setKey( "jsxc.config.online_help" )
        .setDynamic( true )
        .setPlugin( "JSXC" )
        .build();

    public enum Storage {
        implementationDefault,
        localStorage,
        sessionStorage
    }

    public static final SystemProperty<Storage> STORAGE = SystemProperty.Builder.ofType( Storage.class )
        .setKey( "jsxc.config.storage" )
        .setDefaultValue( Storage.implementationDefault )
        .setDynamic( true )
        .setPlugin( "JSXC" )
        .build();

    public static final SystemProperty<List<String>> DISABLED_PLUGINS = SystemProperty.Builder.ofType( List.class )
        .setKey( "jsxc.config.disabled_plugins" )
        .setDefaultValue( Collections.emptyList() )
        .setDynamic( true )
        .setPlugin( "JSXC" )
        .buildList( String.class );

    public static final SystemProperty<Boolean> DEBUG_ENABLED = SystemProperty.Builder.ofType( Boolean.class )
        .setKey( "jsxc.config.debug_enabled" )
        .setDefaultValue( false )
        .setDynamic( true )
        .setPlugin( "JSXC" )
        .build();

    public void doGet( HttpServletRequest request, HttpServletResponse response ) throws ServletException, IOException
    {
        final JSONObject data = doGetConfig(request);
        try ( final Writer writer = response.getWriter() )
        {
            writer.write( data.toString( 2 ) );
            writer.flush();
        }
    }

    protected JSONObject doGetConfig( HttpServletRequest request )
    {
        Log.trace( "Processing doGet() for config" );

        final String endpoint = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + "/http-bind/";

        final Language language = JSXCPlugin.getLanguage();


        final JSONObject config = new JSONObject();
        config.put("service", endpoint);
        config.put("domain", DOMAIN.getValue() );

        if (APP_NAME.getValue() != null) {
            config.put("appName", APP_NAME.getValue());
        }

        if (language != null) {
            config.put("lang", language.getCode());
        }

        if (AUTO_LANG.getValue() != null && !AUTO_LANG.getValue().equals(AUTO_LANG.getDefaultValue())) {
            config.put("autoLang", AUTO_LANG.getValue() == 1);
        }

        if (ROSTER_APPEND.getValue() != null) {
            config.put("rosterAppend", ROSTER_APPEND.getValue());
        }

        if (ROSTER_VISIBILITY.getValue() != null && ROSTER_VISIBILITY.getValue() != ROSTER_VISIBILITY.getDefaultValue() ) {
            config.put("rosterVisibility", ROSTER_VISIBILITY.getValue());
        }

        if (HIDE_OFFLINE_CONTACTS.getValue() != null && !HIDE_OFFLINE_CONTACTS.getValue().equals(HIDE_OFFLINE_CONTACTS.getDefaultValue())) {
            config.put("hideOfflineContacts", HIDE_OFFLINE_CONTACTS.getValue());
        }

        if (RTC_PEER_CONFIG_TTL.getValue() >= 0) {
            if (!config.has("RTCPeerConfig")) {
                config.put("RTCPeerConfig", new JSONObject());
            }
            config.getJSONObject("RTCPeerConfig").put("ttl", RTC_PEER_CONFIG_TTL.getValue());
        }

        if (RTC_PEER_CONFIG_ICE_SERVERS.getValue() != null && !RTC_PEER_CONFIG_ICE_SERVERS.getValue().isEmpty()) {
            if (!config.has("RTCPeerConfig")) {
                config.put("RTCPeerConfig", new JSONObject());
            }
            config.getJSONObject("RTCPeerConfig").put("iceServers", new JSONArray(RTC_PEER_CONFIG_ICE_SERVERS.getValue()));
        }

        if (ONLINE_HELP.getValue() != null) {
            config.put("onlineHelp", ONLINE_HELP.getValue());
        }

        if (STORAGE.getValue() != null && STORAGE.getValue() != STORAGE.getDefaultValue()) {
            config.put("storage", STORAGE.getValue());
        }

        if (DISABLED_PLUGINS.getValue() != null && !DISABLED_PLUGINS.getValue().isEmpty()) {
            config.put("disabledPlugins", new JSONArray(DISABLED_PLUGINS.getValue()));
        }

        if (DEBUG_ENABLED.getValue()) {
            config.put("debug_enabled", true);
        }
        return config;
    }
}
