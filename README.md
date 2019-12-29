# thebotbloglib

A library that can be used to create bots for social media such as Facebook.

To use the ImageManager class you must have ImageCmd compiled in the root folder of your project.

ImageCmd: https://github.com/TheBotBlog/ImageCmd

## Examples

### Createing a service.

```
auto service = new FacebookService("PAGE_ID", "TOKEN");
```

### Creating a post

```
auto post = service.createPost("MESSAGE");
```

### Creating a post with an image

```
auto post = service.createPost("MESSAGE", "IMAGE_URL");
```

### Retrieving a post

```
auto post = service.retrievePost("POST_ID", true);
```

### Updating the link and photo of a retrieved post.

```
post.updateLinkAndPhoto();
```

### Reading comments from a post.

```
auto comments = post.readComments();

while (post.hasMoreComments)
{
  comments ~= post.readNextComments();
}
```

### Getting post reactions

For comments just switch the post out with the comment object.

```
post.updateReacts();

foreach (loveReact; post.loveReacts)
{
  // ...
}
```

### Getting comment reactions

For comments just switch the post out with the comment object.

```
foreach (comment; comments)
{
  comment.updateReacts();

  foreach (loveReact; comment.loveReacts)
  {
    // ...
  }
}
```

**The below examples require ImageCmd**

### Initializing an image

```
auto imageManager = new ImageManager("SOURCE_IMAGE_PATH", "finalized%s.png");

//The final image will be named "finalized.png"
```

### Rotating an image 180 degrees

```
imageManager.rotate180();
```

### Draw an image

```
imageManager.drawImage("IMAGE_PATH", X, Y, WIDTH, HEIGHT);
```

### Draw a rectangle

```
imageManager.drawRectangle(X, Y, WIDTH, HEIGHT, Color.rgb(0,0,0), true);
```

### Drawing text

```
{
  auto textOptions = new TextOptions;
  textOptions.fontName = "Verdana";
  textOptions.fontSize = 42.0;
  textOptions.color = Color.rgb(255, 255, 255);
  textOptions.rect = new Rectangle;
  textOptions.rect.x = 0;
  textOptions.rect.y = 0;
  textOptions.rect.fixedWidth = true;
  textOptions.rect.fixedHeight = true;
  textOptions.centerText = true;

  imageManager.drawText("The text to draw", textOptions);
}
```

### Inversing colors

```
imageManager.inverseColors();
```

### Making the image black and white

```
imageManager.turnBlackAndWhite();
```

### Finalizing the image

```
imageManager.finalize();
```
