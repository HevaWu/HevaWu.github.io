---
layout: post
title: HTTP Accept-Language
date: 2020-07-02 21:55:00
comment_id: 88
categories: [Server]
tags: [Header]
---

Recently we suddenly find the response of `curl` or `Postman` are different with the response of device.

After doing research, we find device auto-adding the `Accept-Language` header in the request part, which cause the different response list.

This is for introducing the `Accept-Language` things.

## Quick-Look

> The `Accept-Language` header is information about the user's language preferences that is passed via HTTP when a document is request.
>
> The value it self is defined by [BCP 47](http://www.rfc-editor.org/rfc/bcp/bcp47.txt), typically as a [two or three letter language code](https://www.w3.org/International/articles/language-tags/) (eg. fr for French), followed by optional subcodes representing such things as country (eg. fr-CA represents French as spoken in Canada).

## Syntax

- specific language selection: `Accept-Language: <language>`
- wild card(selects all languages): `Accept-Language: *`

Multiple languages can be listed by using commas and the optional.

**Directives**

- `<language>`: 2-3 letter base langauge tag representing the language, folowed by sub-tags separated by '-'. The extra information is the region and country variant(ex: 'en-US' or 'fr-CA')
- `*`: used as a wildcard for any language present

It might also contains `;q=`, this defines the factor weighting, value placed in an order of preferences expressed using a relative quality value.

## Example

```s
# In this example single value is on Accept-Language header that is English of US.
accept-language: en-US

# In this example double value is on Accept-Language header that is English of US and French of Canada.
Accept-Language: en-US,fr-CA

# In this example single value is on Accept-Language header that is English of US with the factor weighting.
accept-language: en-US,en;q=0.9
```

## Last

Using `Accept-Language` header is good for determining the language of user, rather than the locale. But it has limitations and give the user some way to override the assumption you added.

Even we are trying to make assumption about locale or region, it should be aware that the programming environment may be making such assumptions on the behalf. Many web servers, server side scripting languages, and operating environments, by default, parse and infer their native locale objects from `Accept-Language`. 

ex: .NET uses the `Accept-Language` to determine the default CultureInfo, Java Servlet provides a `getLocale()` and `getLocales()` of methods that parse `Accept-Language`.

AND A language preference of es-MX doesn't necessarily mean that a postal address form should be formatted or validated for Mexican addresses. The user might still live in the USA (or elsewhere).

#### Reference

<https://www.geeksforgeeks.org/http-headers-accept-language/>

<https://www.w3.org/International/questions/qa-accept-lang-locales.en>
