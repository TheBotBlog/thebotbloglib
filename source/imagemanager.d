/**
* Copyright © The Bot Blog 2019
* License: MIT (https://github.com/TheBotBlog/thebotbloglib/blob/master/LICENSE)
* Author: Jacob Jensen (bausshf)
*/
module thebotbloglib.imagemanager;

import std.conv : to;
import std.string : strip, format;
import std.array : join, replace;
import std.file : exists, remove, copy;

/// Text options.
final class TextOptions
{
  public:
  /// The name of the font to use if no font-file is specified.
  string fontName;
  /// The font file to use if no font-name is specified.
  string fontFile;
  /// The font size.
  float fontSize;
  /// The color of the text.
  Color color;
  /// The rectangle to confine the text within.
  Rectangle rect;
  /// Boolean determining whether to center the text in the given rectangle.
  bool centerText;
}

/// A color
final struct Color
{
  public:
  /// The red channel.
  ubyte r;
  /// The green channel.
  ubyte g;
  /// The blue channel.
  ubyte b;
  /// The alpha channel.
  ubyte a;

  static:
  /**
  * Creates a color from RGB.
  * Params:
  *   r = the red channel.
  *   g = the green channel.
  *   b = The blue channel.
  * Returns:
  *   The color.
  */
  Color rgb(int r, int g, int b)
  {
    return Color(cast(ubyte)r, cast(ubyte)g, cast(ubyte)b, cast(ubyte)255);
  }

  /**
  * Creates a color from RGBA.
  * Params:
  *   r = the red channel.
  *   g = the green channel.
  *   b = The blue channel.
  *   a = The alpha channel.
  * Returns:
  *   The color.
  */
  Color rgba(int r, int g, int b, int a)
  {
    return Color(cast(ubyte)r, cast(ubyte)g, cast(ubyte)b, cast(ubyte)a);
  }
}

/// A rectangle.
final class Rectangle
{
  public:
  /// The x coordinate.
  ptrdiff_t x;
  /// The y coordinate.
  ptrdiff_t y;
  /// The width.
  ptrdiff_t width;
  /// The height.
  ptrdiff_t height;
  /// Boolean determining whether the width is fixed and relative to the image width.
  bool fixedWidth;
  /// Boolean determining whether the height is fixed and relative to the image height.
  bool fixedHeight;
}

/// An image manager.
final class ImageManager
{
  private:
  /// The base image path.
  string _baseImagePath;
  /// The final output path.
  string _finalOutputPath;
  /// The original output path.
  string _originalOutputPath;
  /// The output path.
  string _outputPath;
  /// The counter.
  size_t _counter;

  public:
  final:
  /**
  * Creates a new image manager.
  * Params:
  *   baseImagePath = The base image path.
  *   outputPath = The output image path. This must contain '%s' as a format in the filename. (The final image will not contain the format.)
  */
  this(string baseImagePath, string outputPath)
  {
    _counter = 0;

    _baseImagePath = baseImagePath;

    _finalOutputPath = outputPath.replace("%s", "");
    _originalOutputPath = outputPath;

    _outputPath = _originalOutputPath.format(_counter);
  }

  /**
  * Merges another image on-top.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool merge(string imagePath)
  {
    return runImageCmd("merge", imagePath);
  }

  /**
  * Rotates the image 90 degrees.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool rotate90()
  {
    return runImageCmd("rotate90");
  }

  /**
  * Rotate the image 180 degrees.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool rotate180()
  {
    return runImageCmd("rotate180");
  }

  /**
  * Flips the image horizontal.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool flipHorizontal()
  {
    return runImageCmd("flipH");
  }

  /**
  * Flips the image vertically.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool flipVertical()
  {
    return runImageCmd("flipV");
  }

  /**
  * Inverses the colors.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool inverseColors()
  {
    return runImageCmd("inverse");
  }

  /**
  * Turns the image black and white.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool turnBlackAndWhite()
  {
    return runImageCmd("blackAndWhite");
  }

  /**
  * Draws text on the image.
  * Params:
  *   text = The text to draw.
  *   options = The text drawing options.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool drawText(string text, TextOptions options)
  {
    if (!options || !text || !text.strip.length)
    {
      return false;
    }

    if ((!options.fontName || !options.fontName.strip.length) && (!options.fontFile || !options.fontFile.strip.length))
    {
      return false;
    }

    auto actions = ["drawText"];
    actions ~= "text::" ~ text;

    if (options.fontName && options.fontName.strip.length)
    {
      actions ~= "font::" ~ options.fontName;
    }
    else
    {
      actions ~= "fontFile::" ~ options.fontFile;
    }

    if (options.fontSize >= 1)
    {
      actions ~= "fontSize::" ~ to!string(options.fontSize);
    }

    actions ~= "color::" ~ join([options.color.r.to!string, options.color.g.to!string, options.color.b.to!string, options.color.a.to!string], ",");

    if (options.rect)
    {
      string width = options.rect.fixedWidth ? "*" : to!string(options.rect.width);
      string height = options.rect.fixedHeight ? "*" : to!string(options.rect.height);

      actions ~= "rect::" ~ to!string(options.rect.x) ~ "," ~ to!string(options.rect.y) ~ "," ~ width ~ "," ~ height;
    }

    if (options.centerText)
    {
      actions ~= "centerText::true";
    }

    auto action = join(actions, "||");

    import std.stdio : writeln;
    writeln(action);

    return runImageCmd(action);
  }

  /**
  * Draws a rectangle.
  * Params:
  *   x = The x coordinate.
  *   y = The y coordinate.
  *   width = The width.
  *   height = The height.
  *   color = The color.
  *   fill = (optional) (default = false) Boolean determining whether the rectangle's colors should fill.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool drawRectangle(ptrdiff_t x, ptrdiff_t y, ptrdiff_t width, ptrdiff_t height, Color color, bool fill = false)
  {
    auto action = "drawRect||rect::" ~ to!string(x) ~ "," ~ to!string(y) ~ "," ~ to!string(width) ~ "," ~ to!string(height);
    action ~= "||color::" ~ join([color.r.to!string, color.g.to!string, color.b.to!string, color.a.to!string], ",");

    if (fill)
    {
      action ~= "||fill::true";
    }

    return runImageCmd(action);
  }

  /**
  * Draws a line.
  * Params:
  *   startX = The start x coordinate.
  *   startY = The start y coordinate.
  *   endX = The end x coordinate.
  *   endY = The end y coordinate.
  *   color = The color.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool drawLine(ptrdiff_t startX, ptrdiff_t startY, ptrdiff_t endX, ptrdiff_t endY, Color color)
  {
    auto action = "drawLine||args::" ~ to!string(startX) ~ "," ~ to!string(startY) ~ "," ~ to!string(endX) ~ "," ~ to!string(endY);
    action ~= "||color::" ~ join([color.r.to!string, color.g.to!string, color.b.to!string, color.a.to!string], ",");

    return runImageCmd(action);
  }

  /**
  * Draws an image.
  * Params:
  *   imagePath = The image path.
  *   x = The x coordinate.
  *   y = The y coordinate.
  *   width = The width.
  *   height = The height.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool drawImage(string imagePath, ptrdiff_t x, ptrdiff_t y, ptrdiff_t width, ptrdiff_t height)
  {
    return drawImage(imagePath, x, y, to!string(width), to!string(height));
  }

  /**
  * Draws an image.
  * Params:
  *   imagePath = The image path.
  *   x = The x coordinate.
  *   y = The y coordinate.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool drawImage(string imagePath, ptrdiff_t x, ptrdiff_t y)
  {
    return drawImage(imagePath, x, y, "*", "*");
  }

  /**
  * Draws an image with a custom width.
  * Params:
  *   imagePath = The image path.
  *   x = The x coordinate.
  *   y = The y coordinate.
  *   width = The width.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool drawImageStretchedHorizontal(string imagePath, ptrdiff_t x, ptrdiff_t y, ptrdiff_t width)
  {
    return drawImage(imagePath, x, y, to!string(width), "*");
  }

  /**
  * Draws an image with a custom height.
  * Params:
  *   imagePath = The image path.
  *   x = The x coordinate.
  *   y = The y coordinate.
  *   height = The height.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool drawImageStretchedVertical(string imagePath, ptrdiff_t x, ptrdiff_t y, ptrdiff_t height)
  {
    return drawImage(imagePath, x, y, "*", to!string(height));
  }

  /// Finalizes the image. (Removes the last temp image and creates the final output image file.)
  void finalize()
  {
    copy(_baseImagePath, _finalOutputPath);

    if (exists(_baseImagePath))
    {
      remove(_baseImagePath);
    }
  }

  private:
  /**
  * Draws an image.
  * Params:
  *   imagePath = The image path.
  *   x = The x coordinate.
  *   y = The y coordinate.
  *   width = The width.
  *   height = The height.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool drawImage(string imagePath, ptrdiff_t x, ptrdiff_t y, string width, string height)
  {
    auto size = width ~ "," ~ height;
    auto position = to!string(x) ~ "," ~ to!string(y);

    return runImageCmd("drawImage||size::" ~ size ~ "||position::" ~ position, imagePath);
  }

  /**
  * Runs the ImageCmd with the given parameters.
  * Params:
  *   action = The action / parameters to pass.
  *   sourceImage = (optional) The source image to use.
  * Returns:
  *   True if the action was successfully executed, false otherwise.
  */
  bool runImageCmd(string action, string sourceImage = null)
  {
    import std.process : spawnProcess, wait, Pid;
    import std.string : strip;

    Pid imagePid;
    if (!sourceImage || !sourceImage.strip.length)
    {
      imagePid = spawnProcess(["ImageCmd.exe", _baseImagePath, _outputPath, action]);
    }
    else
    {
      imagePid = spawnProcess(["ImageCmd.exe", _baseImagePath, sourceImage, action, _outputPath]);
    }

    auto result = wait(imagePid);

    if (_counter)
    {
      if (exists(_baseImagePath))
      {
        remove(_baseImagePath);
      }
    }

    _baseImagePath = _outputPath;
    _counter++;
    _outputPath = _originalOutputPath.format(_counter);

    return result == 0;
  }
}
