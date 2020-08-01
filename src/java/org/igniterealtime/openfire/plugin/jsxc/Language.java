/*
 * Copyright (C) 2020 Ignite Realtime Foundation. All rights reserved.
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

import java.util.Locale;

/**
 * Languages as available in JSXC's locale files.
 *
 * @author Guus der Kinderen, guus.der.kinderen@gmail.com
 */
public enum Language
{
    Arabic ("ar"),
    Bulgarian ("bg"),
    Bengali ("bn-BD"),
    Czech ("cs"),
    German ("de"),
    Greek ("el"),
    English ("en"),
    Spanish ("es"),
    Finnish ("fi"),
    French ("fr"),
    Hungarian ("hu-HU"),
    Italian ("it"),
    Japanese ("ja"),
    Dutch ("nl-NL"),
    Polish ("pl"),
    BrazilianPortuguese ("pt-BR"),
    Romanian ("ro"),
    Russian ("ru"),
    Slovak ("sk"),
    Albanian ("sq"),
    Swedish ("sv-SE"),
    Turkish ("tr-TR"),
    Ukrainian ("uk-UA"),
    Vietnamese ("vi-VN"),
    Chinese ("zh"),
    TaiwanChinese ("zh-TW");

    private final String code;

    Language( String code )
    {
        this.code = code;
    }

    public String getCode()
    {
        return code;
    }

    public static Language byJSXCCode( final String jsxcCode )
    {
        for ( final Language language : values() )
        {
            if ( language.getCode().equalsIgnoreCase( jsxcCode ) )
            {
                return language;
            }
        }

        return null;
    }

    public static Language byLocale( final Locale locale )
    {
        for ( final Language language : values() )
        {
            if ( locale.getLanguage().equals( new Locale( language.getCode().replace('-', '_') ).getLanguage() ) )
            {
                return language;
            }
        }

        return null;
    }
}
