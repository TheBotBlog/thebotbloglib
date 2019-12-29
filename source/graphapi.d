/**
* Copyright © The Bot Blog 2019
* License: MIT (https://github.com/TheBotBlog/thebotbloglib/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*
* This module contains interfaces for the Graph API.
*/
module thebotbloglib.graphapi;

import vibe.data.serialization : optional;

package(thebotbloglib):
/// GraphAPIPaging
final class GraphAPIPaging
{
  public:
  /// next
  @optional string next;
  /// cursors
  @optional GraphAPIPagingCursor cursors;
}

/// GraphAPIPagingCursor
final class GraphAPIPagingCursor
{
  public:
  /// before
  @optional string before;
  /// after
  @optional string after;
}

/// GraphAPIComments
final class GraphAPIComments
{
  public:
  /// data
  GraphAPIComment[] data;
  /// paging
  GraphAPIPaging paging;
}

/// GraphAPIComment
final class GraphAPIComment
{
  public:
  /// created_time
  string created_time;
  /// from
  GraphAPICommentUser from;
  /// message
  string message;
  /// id
  string id;
}

/// GraphAPICommentUser
final class GraphAPICommentUser
{
  public:
  /// name
  string name;
  /// id
  string id;
}

/// GraphAPIObjectResponse
final class GraphAPIObjectResponse
{
  public:
  /// id
  string id;
  /// post_id
  @optional string post_id;
}

/// GraphAPIObjectReactions
final class GraphAPIObjectReactions
{
  public:
  /// data
  GraphAPIObjectReact[] data;
  /// paging
  GraphAPIPaging paging;
}

/// GraphAPIObjectReact
final class GraphAPIObjectReact
{
  public:
  /// id
  string id;
  /// name
  string name;
  /// type
  string type;
}
