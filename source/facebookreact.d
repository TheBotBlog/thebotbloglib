/**
* Copyright © The Bot Blog 2019
* License: MIT (https://github.com/TheBotBlog/thebotbloglib/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module thebotbloglib.facebookreact;

/// A Facebook react.
final class FacebookReact
{
  private:
  /// The id of the reaction.
  string _id;
  /// The name of the reaction.
  string _name;
  /// The type of the reaction.
  string _reactionType;

  package(thebotbloglib)
  {
    final:
    /// Creates a new Facebook react.
    this()
    {

    }

    @property
    {
      /// Sets the id of the reaction.
      void id(string newId)
      {
        _id = newId;
      }

      /// Sets the name of the reaction.
      void name(string newName)
      {
        _name = newName;
      }

      /// Sets the type of the reaction.
      void reactionType(string newReactionType)
      {
        _reactionType = newReactionType;
      }
    }
  }

  public:
  final:
  @property
  {
    /// Gets the id of the reaction.
    string id() { return _id; }

    /// Gets the name of the reaction.
    string name() { return _name; }

    /// Gets the type of the reaction.
    string reactionType() { return _reactionType; }
  }
}
