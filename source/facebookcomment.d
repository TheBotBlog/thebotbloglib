/**
* Copyright © The Bot Blog 2019
* License: MIT (https://github.com/TheBotBlog/thebotbloglib/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module thebotbloglib.facebookcomment;

import std.string : strip, toLower;
import std.array : split;
import std.algorithm : count;

import thebotbloglib.webmanager;
import thebotbloglib.facebookservice;
import thebotbloglib.graphapi;
import thebotbloglib.facebookreact;

/// A Facebook comment.
final class FacebookComment
{
  private:
  /// The facebook service.
  FacebookService _service;
  /// The comment id.
  string _commentId;
  /// The id.
  string _id;
  /// The time the comment was created.
  string _createdTime;
  /// The comment's message.
  string _message;
  /// The author's name.
  string _authorName;
  /// The author's id.
  string _authorId;

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
    final:
    /**
    * Creates a new Facebook comment.
    * Params:
    *   service = The Facebook service to associate the comment with.
    */
    this(FacebookService service)
    {
      _service = service;
    }

    @property
    {
      /// Sets the id of the comment.
      void id(string newId)
      {
        _id = newId;
      }

      /// Sets the created time of the comment.
      void createdTime(string newCreatedTime)
      {
        _createdTime = newCreatedTime;
      }

      /// Sets the message of the comment.
      void message(string newMessage)
      {
        _message = newMessage;
      }

      /// Sets the author's name.
      void authorName(string newAuthorName)
      {
        _authorName = newAuthorName;
      }

      /// Sets the author's id.
      void authorId(string authorId)
      {
        _authorId = authorId;
      }
    }
  }

  public:
  final:
  @property
  {
    /// Gets the id.
    string id() { return _id; }

    /// Gets the time the comment was created.
    string createdTime() { return _createdTime; }

    /// Gets the message.
    string message() { return _message; }

    /// Gets the author's name.
    string authorName() { return _authorName; }

    /// Gets the author's id.
    string authorId() { return _authorId; }

    /// Gets the comment id.
    string commentId()
    {
      if (id && id.strip.length && (!_commentId || !_commentId.strip.length))
      {
        auto idData = id.split("_");

        if (idData.length > 1)
        {
          _commentId = idData[1];
        }
      }

      return _commentId;
    }

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
  }

  /// Updates the reaactions.
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

  /**
  * Fills the reactions.
  * Params:
  *   resp = The graph api response.
  *   reacts = (ref) The reaction collection to append to.
  */
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
