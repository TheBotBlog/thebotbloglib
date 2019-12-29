/**
* Copyright © The Bot Blog 2019
* License: MIT (https://github.com/TheBotBlog/thebotbloglib/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module thebotbloglib.facebookservice;

import std.string : strip;

import thebotbloglib.webmanager;
import thebotbloglib.graphapi;
import thebotbloglib.facebookpost;

/// A Facebook service.
final class FacebookService
{
  private:
  /// The page id.
  string _pageId;
  /// The token.
  string _token;
  /// The comment rate limit.
  size_t _commentRateLimit;

  public:
  final:
  /**
  * Creates a new Facebook service.
  * Params:
  *   pageId = The id of the page.
  *   token = The token.
  *   commentRateLimit = (optional) (default = 5000) The rate limit for comments in milliseconds.
  */
  this(string pageId, string token, size_t commentRateLimit = 5000)
  {
    _pageId = pageId;
    _token = token;
    _commentRateLimit = commentRateLimit;
  }

  @property
  {
    /// Gets the page id.
    string pageId() { return _pageId; }

    /// Gets the token.
    string token() { return _token; }

    /// Gets the comment rate limit.
    size_t commentRateLimit() { return _commentRateLimit; }
  }

  /**
  * Creates a post. If no photo is specified then an empty 400x1 image is attached.
  * Params:
  *   message = The message of the post.
  *   photo = (optional) The photo of the post. This must be an URL.
  * Returns:
  *   The newly created Facebook post.
  */
  FacebookPost createPost(string message, string photo = null)
  {
    auto web = new WebManager(this);

    string[string] data;
    data["caption"] = message;

    if (!photo || !photo.strip.length)
    {
      data["url"] = "https://cdn.discordapp.com/attachments/577173321054027784/631755165644357643/400x1.png";
    }
    else
    {
      data["url"] = photo;
    }

    auto resp = web.postRequest!GraphAPIObjectResponse(pageId, "photos", data);

    return resp ? new FacebookPost(this, resp.id) : null;
  }

  /**
  * Retrieves a Facebook post.
  * Params:
  *   id = The id of the post to retrieve.
  *   readPost = A boolean determining whether the post information should be read or not.
  * Returns:
  *   The retrieved Facebook post.
  */
  FacebookPost retrievePost(string id, bool readPost = false)
  {
    auto post = new FacebookPost(this, id);

    if (readPost)
    {
      post.updatePostInfo();
    }

    return post;
  }
}
