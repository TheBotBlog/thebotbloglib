/**
* Copyright © The Bot Blog 2019
* License: MIT (https://github.com/TheBotBlog/thebotbloglib/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module thebotbloglib.facebookpost;

import std.string : strip, toLower;
import std.array : split, join;
import std.algorithm : count;

import vibe.d : Json;

import thebotbloglib.webmanager;
import thebotbloglib.facebookservice;
import thebotbloglib.graphapi;
import thebotbloglib.facebookcomment;
import thebotbloglib.facebookreact;

/// A Facebook post.
final class FacebookPost
{
  private:
  /// The Facebook service associated with the post.
  FacebookService _service;
  /// The id of the post.
  string _id;
  /// The next comment url.
  string _nextCommentUrl;

  /// The time the post was created.
  string _createdTime;
  /// The message of the post.
  string _message;
  /// The link of the post.
  string _link;
  /// The picture of the post.
  string _picture;

  /// All the like reactions.
  FacebookReact[] _likeReacts;
  /// All the love reactions.
  FacebookReact[] _loveReacts;
  /// All the wow reactions.
  FacebookReact[] _wowReacts;
  /// All the haha reactions.
  FacebookReact[] _hahaReacts;
  /// All the sad reactions.
  FacebookReact[] _sadReacts;
  /// All the angry reactions.
  FacebookReact[] _angryReacts;

  /// The total amount of reactions.
  size_t _totalReacts;
  /// The total amount of positive reactions.
  size_t _totalPositiveReacts;
  /// The total amount of inclusive positive reactions.
  size_t _totalInclusivePositiveReacts;
  /// The total amount of negative reactions.
  size_t _totalNegativeReacts;
  /// The total reaction rate.
  ptrdiff_t _totalReactionRate;

  package(thebotbloglib)
  {
    /**
    * Creates a new Facebook post.
    * Params:
    *   service = The Facebook service to associate the post with.
    *   id = The id of the post.
    */
    this(FacebookService service, string id)
    {
      _service = service;
      _id = id;
    }
  }

  public:
  final:
  @property
  {
    /// Gets the id of the post.
    string id() { return _id; }

    /// Gets the time the post was created.
    string createdTime() { return _createdTime; }

    /// Gets the message of the post.
    string message() { return _message; }

    /// Gets the link of the post.
    string link() { return _link; }

    /// Gets the picture of the post.
    string picture() { return _picture; }

    /// Gets the like reactions.
    FacebookReact[] likeReacts() { return _likeReacts; }

    /// Gets the love reactions.
    FacebookReact[] loveReacts() { return _loveReacts; }

    /// Gets the wow reactions.
    FacebookReact[] wowReacts() { return _wowReacts; }

    /// Gets the haha reactions.
    FacebookReact[] hahaReacts() { return _hahaReacts; }

    /// Gets sad reactions.
    FacebookReact[] sadReacts() { return _sadReacts; }

    /// Gets the angry reactions.
    FacebookReact[] angryReacts() { return _angryReacts; }

    /// Gets the total reactions.
    size_t totalReacts() { return _totalReacts; }

    /// Gets the total positive reactions.
    size_t totalPositiveReacts() { return _totalPositiveReacts; }

    /// Gets the total inclusive positive reactions.
    size_t totalInclusivePositiveReacts() { return _totalInclusivePositiveReacts; }

    /// Gets the total negative reactions.
    size_t totalNegativeReacts() { return _totalNegativeReacts; }

    /// Gets the totoal reaction rate.
    ptrdiff_t totalReactionRate() { return _totalReactionRate; }

    /// Gets a boolean determining whether there are more comments to load.
    bool hasMoreComments()
    {
      return _nextCommentUrl && _nextCommentUrl.strip.length;
    }
  }

  /// Updates the post link and picture.
  void updateLinkAndPhoto()
  {
    updatePostInfo(["link", "picture"]);
  }

  /**
  * Updates the post information.
  * Params:
  *   fields = An array of field names to update.
  *   fieldReader = A custom reader for fields.
  */
  void updatePostInfo(string[] fields = null, void delegate(string,Json) fieldReader = null)
  {
    _nextCommentUrl = null;

    auto web = new WebManager(_service);

    string[string] parameters;

    if (fields && fields.length)
    {
      parameters["fields"] = join(fields, ",");
    }

    auto resp = web.getRequest!Json(id, null, parameters);

    foreach (k,v; resp.byKeyValue)
    {
      switch (k)
      {
        case "created_time":
          _createdTime = v.to!string;
          break;

        case "name":
          _message = v.to!string;
          break;

        case "link":
          _link = v.to!string;
          break;

        case "picture":
          _picture = v.to!string;
          break;

        default: break;
      }

      if (fieldReader)
      {
        fieldReader(k, v);
      }
    }
  }

  /**
  * Reads the first set of comments from the post.
  * Use readNextComments() to read the next set of comments.
  * Params:
  *   order = The order of the comments.
  * Returns:
  *   An array with the comments from the first set.
  */
  FacebookComment[] readComments(string order = "chronological")
  {
    _nextCommentUrl = null;

    FacebookComment[] comments = [];

    auto web = new WebManager(_service);

    string[string] parameters;
    parameters["order"] = order;

    auto resp = web.getRequest!GraphAPIComments(id, "comments", parameters);

    fillComments(resp, comments);

    return comments;
  }

  /**
  * Reads the next set of comments from the post.
  * Make sure to check hasMoreComments before calling this.
  * Returns:
  *   An array with the comments from the next set.
  */
  FacebookComment[] readNextComments()
  {
    FacebookComment[] comments = [];

    auto web = new WebManager(_service);

    auto resp = web.getRequestRaw!GraphAPIComments(_nextCommentUrl);

    _nextCommentUrl = null;

    fillComments(resp, comments);

    return comments;
  }

  /**
  * Fills the comments.
  * Params:
  *   resp = The graph api response.
  *   comments = (ref) The comment collection to append to.
  */
  private void fillComments(GraphAPIComments resp, ref FacebookComment[] comments)
  {
    if (resp && resp.data && resp.data.length)
    {
      foreach (data; resp.data)
      {
        auto comment = new FacebookComment(_service);

        comment.id = data.id;
        comment.createdTime = data.created_time;
        comment.message = data.message;
        comment.authorName = data.from ? data.from.name : null;
        comment.authorId = data.from ? data.from.id : null;

        comments ~= comment;
      }

      if (resp.paging && resp.paging.next && resp.paging.next.strip.length)
      {
        _nextCommentUrl = resp.paging.next;
      }
    }
  }

  /**
  * Writes a comment on the post.
  * Params:
  *   message = The message of the comment. This value can be null.
  *   photo = (optional) The photo of the comment.
  * Returns:
  *   The id of the new comment.
  */
  string writeComment(string message, string photo = null)
  {
    auto web = new WebManager(_service);

    string[string] data;

    if (message && message.strip.length)
    {
      data["message"] = message;
    }

    if (photo && photo.strip.length)
    {
      data["attachment_url"] = photo;
    }

    auto resp = web.postRequest!GraphAPIObjectResponse(id, "comments", data);

    if (_service.commentRateLimit)
    {
      import core.thread;

      Thread.sleep(_service.commentRateLimit.msecs);
    }

    return resp.id;
  }

  /**
  * Appends a comment to another comment.
  * Params:
  *   commentId = The id of the comment to append to.
  *   message = The message of the new comment. This value can be null.
  *   photo = (optional) The photo of the new comment.
  * Returns:
  *   The id of the new comment.
  */
  string appendComment(string commentId, string message, string photo = null)
  {
    auto web = new WebManager(_service);

    string[string] data;

    if (message && message.strip.length)
    {
      data["message"] = message;
    }

    if (photo && photo.strip.length)
    {
      data["attachment_url"] = photo;
    }

    auto resp = web.postRequest!GraphAPIObjectResponse(commentId, "comments", data);

    if (_service.commentRateLimit)
    {
      import core.thread;

      Thread.sleep(_service.commentRateLimit.msecs);
    }

    return resp.id;
  }

  /// Updates the reactions of the post.
  void updateReacts()
  {
    FacebookReact[] reacts = [];

    auto web = new WebManager(_service);

    string[string] data;

    auto resp = web.getRequest!GraphAPIObjectReactions(id, "reactions", data);

    auto nextUrl = fillReacts(resp, reacts);

    while (nextUrl && nextUrl.strip.length)
    {
      resp = web.getRequestRaw!GraphAPIObjectReactions(nextUrl);

      nextUrl = fillReacts(resp, reacts);
    }

    _totalReacts = reacts.count!(r => r.reactionType != "none");

    _likeReacts = [];
    _loveReacts = [];
    _wowReacts = [];
    _hahaReacts = [];
    _sadReacts = [];
    _angryReacts = [];

    foreach (react; reacts)
    {
      switch (react.reactionType)
      {
        case "like": _likeReacts ~= react; break;
        case "love": _loveReacts ~= react; break;
        case "wow": _wowReacts ~= react; break;
        case "haha": _hahaReacts ~= react; break;
        case "sad": _sadReacts ~= react; break;
        case "angry": _angryReacts ~= react; break;

        default: break;
      }
    }

    _totalPositiveReacts = (_likeReacts.length + _loveReacts.length);
    _totalInclusivePositiveReacts = (_totalPositiveReacts + _hahaReacts.length);
    _totalNegativeReacts = (_sadReacts.length + _angryReacts.length);

    _totalReactionRate = _totalPositiveReacts - _angryReacts.length;
  }

  private string fillReacts(GraphAPIObjectReactions resp, ref FacebookReact[] reacts)
  {
    if (resp && resp.data && resp.data.length)
    {
      foreach (data; resp.data)
      {
        auto react = new FacebookReact;
        react.id = data.id;
        react.name = data.name;
        react.reactionType = data.type.toLower.strip;

        reacts ~= react;
      }

      if (resp.paging && resp.paging.next && resp.paging.next.strip.length)
      {
        return resp.paging.next;
      }
    }

    return null;
  }
}
