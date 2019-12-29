/**
* Copyright © The Bot Blog 2019
* License: MIT (https://github.com/TheBotBlog/thebotbloglib/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module thebotbloglib.webmanager;

import std.string : strip, format;
import std.array : join;
import std.algorithm : map;
import std.net.curl : get, post;

import vibe.d : deserializeJson;

import thebotbloglib.facebookservice;
import thebotbloglib.exceptions;

package(thebotbloglib):
/// A web manager.
final class WebManager
{
  /// The Facebook service associated with the manager.
  private FacebookService _service;

  /// The base url for the manager.
  private string _baseUrl;

  /**
  * Creates a new web manager.
  * Params:
  *   service = The service of the web manager.
  */
  this(FacebookService service)
  {
    _service = service;

    _baseUrl = "https://graph.facebook.com/%s/%s%s";
  }

  /**
  * Gets a raw GET request and deserializes it as json.
  * Params:
  *   rawUrl = The url of the GET request.
  * Returns:
  *   Returns the deserialized json object.
  */
  T getRequestRaw(T)(string rawUrl)
  {
    if (!rawUrl || !rawUrl.strip.length)
    {
      throw new WebException("Missing url.");
    }

    auto result = cast(string)get(rawUrl);

    auto obj = deserializeJson!T(result);

    return obj;
  }

  /**
  * Gets a raw POST request and deserializes it as json.
  * Params:
  *   rawUrl = The url of the POST request.
  *   data = The data of the POST request.
  * Returns:
  *   Returns the deserialized json object.
  */
  T postRequestRaw(T)(string rawUrl, string[string] data)
  {
    if (!rawUrl || !rawUrl.strip.length)
    {
      throw new WebException("Missing url.");
    }

    auto result = cast(string)post(rawUrl, data);

    import std.stdio : writeln, readln;
    writeln(result);
    readln();

    auto obj = deserializeJson!T(result);

    return obj;
  }

  /**
  * Creates a GET request and deserializes the response as json.
  * Params:
  *   id = The id of the request.
  *   call = The graph api call of the request.
  *   parameters = The parameters associated with the request.
  * Returns:
  *   Returns the deserialized json object.
  */
  T getRequest(T)(string id, string call, string[string] parameters)
  {
    parameters["access_token"] = _service.token;

    string[] parametersMapped = [];

    foreach (k,v; parameters)
    {
      parametersMapped ~= format("%s=%s", k, v);
    }

    auto query = "?" ~ join(parametersMapped, "&");
    auto formattedUrl = format(_baseUrl, id, call ? call : "", query);

    return getRequestRaw!T(formattedUrl);
  }

  /**
  * Creates a POST request and deserializes the response as json.
  * Params:
  *   id = The id of the request.
  *   call = The graph api call of the request.
  *   parameters = The parameters associated with the request.
  * Returns:
  *   Returns the deserialized json object.
  */
  T postRequest(T)(string id, string call, string[string] parameters)
  {
    parameters["access_token"] = _service.token;

    auto formattedUrl = format(_baseUrl, id, call ? call : "", "");

    return postRequestRaw!T(formattedUrl, parameters);
  }
}
