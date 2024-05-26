#!/usr/bin/env ruby
require 'chunky_png'

# Define the 32-color palette
PALETTE = [
  ChunkyPNG::Color.rgb(0, 0, 0),       # #000000
  ChunkyPNG::Color.rgb(126, 37, 83),   # #7e2553
  ChunkyPNG::Color.rgb(195, 0, 46),    # #c3002e
  ChunkyPNG::Color.rgb(255, 0, 77),    # #ff004d
  ChunkyPNG::Color.rgb(255, 102, 0),   # #ff6600
  ChunkyPNG::Color.rgb(255, 163, 0),   # #ffa300
  ChunkyPNG::Color.rgb(255, 236, 39),  # #ffec27
  ChunkyPNG::Color.rgb(255, 255, 125), # #ffff7d
  ChunkyPNG::Color.rgb(167, 247, 53),  # #a7f735
  ChunkyPNG::Color.rgb(0, 228, 54),    # #00e436
  ChunkyPNG::Color.rgb(0, 178, 81),    # #00b251
  ChunkyPNG::Color.rgb(0, 135, 81),    # #008751
  ChunkyPNG::Color.rgb(18, 83, 89),    # #125359
  ChunkyPNG::Color.rgb(29, 43, 83),    # #1d2b53
  ChunkyPNG::Color.rgb(10, 98, 190),   # #0a62be
  ChunkyPNG::Color.rgb(41, 173, 255),  # #29adff
  ChunkyPNG::Color.rgb(131, 235, 245), # #83ebf5
  ChunkyPNG::Color.rgb(255, 241, 232), # #fff1e8
  ChunkyPNG::Color.rgb(255, 204, 170), # #ffccaa
  ChunkyPNG::Color.rgb(212, 142, 111), # #d48e6f
  ChunkyPNG::Color.rgb(171, 82, 54),   # #ab5236
  ChunkyPNG::Color.rgb(116, 47, 41),   # #742f29
  ChunkyPNG::Color.rgb(66, 33, 54),    # #422136
  ChunkyPNG::Color.rgb(95, 52, 126),   # #5f347e
  ChunkyPNG::Color.rgb(219, 55, 184),  # #db37b8
  ChunkyPNG::Color.rgb(255, 119, 168), # #ff77a8
  ChunkyPNG::Color.rgb(255, 172, 197), # #ffacc5
  ChunkyPNG::Color.rgb(189, 154, 223), # #bd9adf
  ChunkyPNG::Color.rgb(131, 118, 156), # #83769c
  ChunkyPNG::Color.rgb(95, 87, 79),    # #5f574f
  ChunkyPNG::Color.rgb(162, 136, 121), # #a28879
  ChunkyPNG::Color.rgb(194, 195, 199)  # #c2c3c7
]

# Method to find the closest color in the palette
def closest_color(r, g, b)
  PALETTE.min_by do |color|
    pr, pg, pb = ChunkyPNG::Color.to_truecolor_bytes(color)
    (pr - r)**2 + (pg - g)**2 + (pb - b)**2
  end
end

def scale_and_recolor(source, width, height)
  image = ChunkyPNG::Image.from_file(source)

  scaled_image = image.resample_nearest_neighbor(width, height)

  new_image = ChunkyPNG::Image.new(width, height)

  width.times do |x|
    height.times do |y|
      old_pixel = scaled_image[x, y]
      r, g, b = ChunkyPNG::Color.to_truecolor_bytes(old_pixel)
      new_pixel = closest_color(r, g, b)
      new_image[x, y] = new_pixel

      er = r - ChunkyPNG::Color.r(new_pixel)
      eg = g - ChunkyPNG::Color.g(new_pixel)
      eb = b - ChunkyPNG::Color.b(new_pixel)

      distribute_error(scaled_image, x + 1, y,     er, eg, eb, 7 / 16.0)
      distribute_error(scaled_image, x - 1, y + 1, er, eg, eb, 3 / 16.0)
      distribute_error(scaled_image, x,     y + 1, er, eg, eb, 5 / 16.0)
      distribute_error(scaled_image, x + 1, y + 1, er, eg, eb, 1 / 16.0)
    end
  end

  output_path = "output/#{File.basename(source, '.*')}_stenberg_#{width}x#{height}.png"
  new_image.save(output_path)

  puts "Image saved to #{output_path}"
end

def distribute_error(image, x, y, er, eg, eb, factor)
  return if x < 0 || x >= image.width || y < 0 || y >= image.height

  r, g, b = ChunkyPNG::Color.to_truecolor_bytes(image[x, y])
  r = (r + er * factor).clamp(0, 255).to_i
  g = (g + eg * factor).clamp(0, 255).to_i
  b = (b + eb * factor).clamp(0, 255).to_i
  image[x, y] = ChunkyPNG::Color.rgb(r, g, b)
end

# Command line arguments
if ARGV.length != 3
  puts "Usage: #{$0} source_image.png width height"
  exit 1
end

source_image = ARGV[0]
width = ARGV[1].to_i
height = ARGV[2].to_i

scale_and_recolor(source_image, width, height)
