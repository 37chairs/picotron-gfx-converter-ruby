# picotron gfx converter

This script resizes and crops an image to the desired size, then uses the Stenberg effect to convert it to a color palette compatible with Picotron. The Stenberg effect is a dithering algorithm that helps to spread out color differences in a way that is more visually appealing than a simple color reduction.

![Converted Image](https://raw.githubusercontent.com/37chairs/picotron-gfx-converter-ruby/master/output/background%205_stenberg_480x270.png)

## Installing

The only dependencies are Ruby and chunky_png. 

```zsh
% bundle install
```

## Using

To convert something like a background:

```zsh
% bundle exec ruby convert_image_stenberg_effect.rb background\ 5.png 470 270
```

You can then drag the image into the Picotron editor. 

## Contributing

Feel free to submit a PR with any improvements or bug fixes.  
