#!/usr/bin/env ruby
=begin
"""
Convert values between RGB hex codes and xterm-256 color codes.
Nice long listing of all 256 colors and their codes. Useful for
developing console color themes, or even script output schemes.
The legacy version uses naive euclidean distance in rgb space,
the non-legacy version uses naive euclidean distance in hsv space, manually
tweaked to work better with low values colors
Thanks to Micah Elliott for the legacy version that I used in the beginning
"""

import sys
import re

from typing import Tuple, Dict

__author__ = "Gerry Agbobada (@gagbo)"
__version__ = "0.1"
__copyright__ = "Copyright (C) 2019 Gerry Agbobada.  All rights reserved."
__license__ = "MIT"
=end
# ---------------------------------------------------------------------


CLUT = [  # color look-up table
    #    8-bit, RGB hex
    # Primary 3-bit (8 colors). Unique representation!
    # Equivalent "bright" versions of original 8 colors.
    # They are removed because they usually conflict with
    # Terminal emulators colorschemes
    # Strictly ascending.
    ["16", "000000"],
    ["17", "00005f"],
    ["18", "000087"],
    ["19", "0000af"],
    ["20", "0000d7"],
    ["21", "0000ff"],
    ["22", "005f00"],
    ["23", "005f5f"],
    ["24", "005f87"],
    ["25", "005faf"],
    ["26", "005fd7"],
    ["27", "005fff"],
    ["28", "008700"],
    ["29", "00875f"],
    ["30", "008787"],
    ["31", "0087af"],
    ["32", "0087d7"],
    ["33", "0087ff"],
    ["34", "00af00"],
    ["35", "00af5f"],
    ["36", "00af87"],
    ["37", "00afaf"],
    ["38", "00afd7"],
    ["39", "00afff"],
    ["40", "00d700"],
    ["41", "00d75f"],
    ["42", "00d787"],
    ["43", "00d7af"],
    ["44", "00d7d7"],
    ["45", "00d7ff"],
    ["46", "00ff00"],
    ["47", "00ff5f"],
    ["48", "00ff87"],
    ["49", "00ffaf"],
    ["50", "00ffd7"],
    ["51", "00ffff"],
    ["52", "5f0000"],
    ["53", "5f005f"],
    ["54", "5f0087"],
    ["55", "5f00af"],
    ["56", "5f00d7"],
    ["57", "5f00ff"],
    ["58", "5f5f00"],
    ["59", "5f5f5f"],
    ["60", "5f5f87"],
    ["61", "5f5faf"],
    ["62", "5f5fd7"],
    ["63", "5f5fff"],
    ["64", "5f8700"],
    ["65", "5f875f"],
    ["66", "5f8787"],
    ["67", "5f87af"],
    ["68", "5f87d7"],
    ["69", "5f87ff"],
    ["70", "5faf00"],
    ["71", "5faf5f"],
    ["72", "5faf87"],
    ["73", "5fafaf"],
    ["74", "5fafd7"],
    ["75", "5fafff"],
    ["76", "5fd700"],
    ["77", "5fd75f"],
    ["78", "5fd787"],
    ["79", "5fd7af"],
    ["80", "5fd7d7"],
    ["81", "5fd7ff"],
    ["82", "5fff00"],
    ["83", "5fff5f"],
    ["84", "5fff87"],
    ["85", "5fffaf"],
    ["86", "5fffd7"],
    ["87", "5fffff"],
    ["88", "870000"],
    ["89", "87005f"],
    ["90", "870087"],
    ["91", "8700af"],
    ["92", "8700d7"],
    ["93", "8700ff"],
    ["94", "875f00"],
    ["95", "875f5f"],
    ["96", "875f87"],
    ["97", "875faf"],
    ["98", "875fd7"],
    ["99", "875fff"],
    ["100", "878700"],
    ["101", "87875f"],
    ["102", "878787"],
    ["103", "8787af"],
    ["104", "8787d7"],
    ["105", "8787ff"],
    ["106", "87af00"],
    ["107", "87af5f"],
    ["108", "87af87"],
    ["109", "87afaf"],
    ["110", "87afd7"],
    ["111", "87afff"],
    ["112", "87d700"],
    ["113", "87d75f"],
    ["114", "87d787"],
    ["115", "87d7af"],
    ["116", "87d7d7"],
    ["117", "87d7ff"],
    ["118", "87ff00"],
    ["119", "87ff5f"],
    ["120", "87ff87"],
    ["121", "87ffaf"],
    ["122", "87ffd7"],
    ["123", "87ffff"],
    ["124", "af0000"],
    ["125", "af005f"],
    ["126", "af0087"],
    ["127", "af00af"],
    ["128", "af00d7"],
    ["129", "af00ff"],
    ["130", "af5f00"],
    ["131", "af5f5f"],
    ["132", "af5f87"],
    ["133", "af5faf"],
    ["134", "af5fd7"],
    ["135", "af5fff"],
    ["136", "af8700"],
    ["137", "af875f"],
    ["138", "af8787"],
    ["139", "af87af"],
    ["140", "af87d7"],
    ["141", "af87ff"],
    ["142", "afaf00"],
    ["143", "afaf5f"],
    ["144", "afaf87"],
    ["145", "afafaf"],
    ["146", "afafd7"],
    ["147", "afafff"],
    ["148", "afd700"],
    ["149", "afd75f"],
    ["150", "afd787"],
    ["151", "afd7af"],
    ["152", "afd7d7"],
    ["153", "afd7ff"],
    ["154", "afff00"],
    ["155", "afff5f"],
    ["156", "afff87"],
    ["157", "afffaf"],
    ["158", "afffd7"],
    ["159", "afffff"],
    ["160", "d70000"],
    ["161", "d7005f"],
    ["162", "d70087"],
    ["163", "d700af"],
    ["164", "d700d7"],
    ["165", "d700ff"],
    ["166", "d75f00"],
    ["167", "d75f5f"],
    ["168", "d75f87"],
    ["169", "d75faf"],
    ["170", "d75fd7"],
    ["171", "d75fff"],
    ["172", "d78700"],
    ["173", "d7875f"],
    ["174", "d78787"],
    ["175", "d787af"],
    ["176", "d787d7"],
    ["177", "d787ff"],
    ["178", "d7af00"],
    ["179", "d7af5f"],
    ["180", "d7af87"],
    ["181", "d7afaf"],
    ["182", "d7afd7"],
    ["183", "d7afff"],
    ["184", "d7d700"],
    ["185", "d7d75f"],
    ["186", "d7d787"],
    ["187", "d7d7af"],
    ["188", "d7d7d7"],
    ["189", "d7d7ff"],
    ["190", "d7ff00"],
    ["191", "d7ff5f"],
    ["192", "d7ff87"],
    ["193", "d7ffaf"],
    ["194", "d7ffd7"],
    ["195", "d7ffff"],
    ["196", "ff0000"],
    ["197", "ff005f"],
    ["198", "ff0087"],
    ["199", "ff00af"],
    ["200", "ff00d7"],
    ["201", "ff00ff"],
    ["202", "ff5f00"],
    ["203", "ff5f5f"],
    ["204", "ff5f87"],
    ["205", "ff5faf"],
    ["206", "ff5fd7"],
    ["207", "ff5fff"],
    ["208", "ff8700"],
    ["209", "ff875f"],
    ["210", "ff8787"],
    ["211", "ff87af"],
    ["212", "ff87d7"],
    ["213", "ff87ff"],
    ["214", "ffaf00"],
    ["215", "ffaf5f"],
    ["216", "ffaf87"],
    ["217", "ffafaf"],
    ["218", "ffafd7"],
    ["219", "ffafff"],
    ["220", "ffd700"],
    ["221", "ffd75f"],
    ["222", "ffd787"],
    ["223", "ffd7af"],
    ["224", "ffd7d7"],
    ["225", "ffd7ff"],
    ["226", "ffff00"],
    ["227", "ffff5f"],
    ["228", "ffff87"],
    ["229", "ffffaf"],
    ["230", "ffffd7"],
    ["231", "ffffff"],
    # Gray-scale range.
    ["232", "080808"],
    ["233", "121212"],
    ["234", "1c1c1c"],
    ["235", "262626"],
    ["236", "303030"],
    ["237", "3a3a3a"],
    ["238", "444444"],
    ["239", "4e4e4e"],
    ["240", "585858"],
    ["241", "626262"],
    ["242", "6c6c6c"],
    ["243", "767676"],
    ["244", "808080"],
    ["245", "8a8a8a"],
    ["246", "949494"],
    ["247", "9e9e9e"],
    ["248", "a8a8a8"],
    ["249", "b2b2b2"],
    ["250", "bcbcbc"],
    ["251", "c6c6c6"],
    ["252", "d0d0d0"],
    ["253", "dadada"],
    ["254", "e4e4e4"],
    ["255", "eeeeee"],
]

#===============================
# HELPER FUNCTIONS
#===============================

def strip_hash(hexstring)
    #Strip leading `#` if exists.
    if hexstring.start_with?("#")
        hexstring = hexstring.lstrip("#")
    end
    hexstring
end


def hex2rgb(hexstring)
   # Break 6-char RGB code into 3 integer vals.
   #puts "HEX2RGB RECEIVED: #{hexstring.inspect}"
    rgb = strip_hash(hexstring)
    #puts "AFTER STRIP: #{rgb.inspect}"
    rgb.scan(/../).map {|h| h.to_i(16)}
end

def rgb2hex(r, g, b)
  format('%02x%02x%02x', r, g, b)
end


def rgb2hsv(r,g,b)
    r_f = r/255.0
    g_f = g/255.0
    b_f = b/255.0

    c_min = [r_f, g_f, b_f].min
    c_max = [r_f, g_f, b_f].max
    delta = c_max - c_min

    # Hue
    if delta == 0
        hue = 0.0
    elsif c_max == r_f
        hue = 60.0 * ((g_f - b_f) / delta % 6)
    elsif c_max == g_f
        hue = 60.0 * ((b_f - r_f) / delta + 2)
    else
        hue = 60.0 * ((r_f - g_f) / delta + 4)
    end

    # Saturation
    if c_max == 0
        sat = 0.0
    else
        sat = delta / c_max
    end

    # Value
    val = c_max

    #return (
    [hue.round(2), sat.round(2), val.round(2)]
end

def hex2hsv(hexstring)
    r, g, b = hex2rgb(hexstring)
    rgb2hsv(r, g, b)
end


#============================
# DISTANCE FUNCTIONS
#============================

def hsv_distance(a, b)
    hue_diff = ((a[0] - b[0]) + 180) % 360 - 180
    hue_dist = (hue_diff.abs / 360.0) ** 2
    sat_dist = (a[1] - b[1]).abs ** 2
    val_dist = (a[2] - b[2]).abs ** 1
    hue_dist + sat_dist + val_dist
end


#===========================
# DICTIONARY CREATION
#===========================
def create_dicts
    short2rgb = {}
    rgb2short  = {}
    short2hsv = {}
    hsv2short = {}

    CLUT.each do |short, rgb|
        short2rgb[short] = rgb
        rgb2short[rgb] = short
        hsv = hex2hsv(rgb)
        short2hsv[short] = hsv
        hsv2short[hsv] = short
    end
    #return 
    [rgb2short, short2rgb, short2hsv, hsv2short]
end


RGB2SHORT, SHORT2RGB, SHORT2HSV, HSV2SHORT = create_dicts

#================================
# PUBLIC API
#================================

def short2rgb(short)
  SHORT2RGB[short]
end

def short2hsv(short)
    SHORT2HSV[short]
end


def rgb2short_legacy(hexstring)
    incs = [0x00, 0x5F, 0x87, 0xAF, 0xD7, 0xFF]
    # Break 6-char RGB code into 3 integer vals.
    r, g, b = hex2rgb(hexstring)
    #parts = hex2rgb(hexstring)
    res_parts = [r,g,b].map do |part|
    #for part in parts:
        i = 0
        while i < incs.length - 1
            s, b_val = incs[i], incs[i + 1]  # smaller, bigger
            if s <= part &&  part <= b_val
                s1 = (s - part).abs
                b1 = (b_val - part).abs
                closest = s if s1 < b1 else b_val
                #res_parts.append(closest)
                break
            end
            i += 1
        end
    end
            # print '***', res
    res = res_parts.map{|p| format('%02x', p)}.join#"".join([("%02.x" % i) for i in res_parts])
    equiv = RGB2SHORT[res]
    # print '***', res, equiv
    [equiv, res]
end


def rgb2short(hexstring)
    hsv = hex2hsv(hexstring)
    result = hsv2short(hsv)
    [result, SHORT2RGB[result]]
end

def hsv2short(hsv)
   # """
    #Return the xterm palette color of the closest candidate in
    #hue, saturation and value
    #"""
    SHORT2HSV.min_by {|_, hsv_val| hsv_distance(hsv_val, hsv) }&.first
end
    #xterm_val, xterm_hsv = min(
     #   SHORT2HSV.items(), key=lambda kv_pair: _hsvdistance(kv_pair[1], hsv)
   # )
    #return xterm_val










#=============================
# PRINTING
#=============================

def print_all()
    #"""
    #Print all 256 xterm color codes.
    #"""
    CLUT.each do |short, rgb|
    #for short, rgb in CLUT:
        print "\033[48;5;#{short}m#{short}:#{rgb}\033[0m  "
        print "\033[38;5;#{short}m#{short}:#{rgb}\033[0m\n"
    end
    print "Printed all codes."
    print "You can translate a hex or 0-255 code by providing an argument."
end

def gchalk_rgb_to_ansi256(red, green, blue) 
	# Originally from // From https://github.com/Qix-/color-convert/blob/3f0e0d4e92e235796ccb17f6e85c72094a651f49/conversions.js

	# We use the extended greyscale palette here, with the exception of
	# black and white. normal palette only has 4 greyscale shades.
	if red == green && green == blue #{
		if red < 8
			return 16
        end

		if red > 248
			return 231
        end

		#return uint8(math.Round(((float64(red)-8)/247)*24)) + 232
        return 232 + (((red.to_f-8)/247.0)*24).round
    end

	return 16 +
		#uint8(
        (36 *((red.to_f/255.0)*5).round) + (6*((green.to_f/255.0)*5).round) + ((blue.to_f/255.0)*5).round

			#(36*math.Round(float64(red)/255*5))+
			#	(6*math.Round(float64(green)/255*5))+
			#	math.Round(float64(blue)/255*5))
#}
end

def crayon2_rgb_to_index(r,g,b)
    r = [[r, 0].max, 255].min
    g = [[g, 0].max, 255].min
    b = [[b, 0].max, 255].min

    max_c = [r,g,b].max
    min_c = [r,g,b].min
    avg = (r+g+b)/3
    spread = max_c - min_c

    puts "2nd OLD CRAYON: RGB(#{r},#{g},#{b})    |   SPREAD: #{spread} |  AVERAGE: #{avg}"

    if spread <= 20 && avg > 5
        gray_val = avg
        gray_val = 8 if gray_val < 8
        gray_val = 238 if gray_val > 238
        return 232 + (gray_val - 8)/10
    end


    r6 = (r * 5 + 127) / 255
    g6 = (g * 5 + 127) / 255
    b6 = (b * 5 + 127) / 255
    return 16 + 36 * r6 + 6 * g6 +b6
end


def hybrid_rgb_to_index(r,g,b)
    r = [[r, 0].max, 255].min
    g = [[g, 0].max, 255].min
    b = [[b, 0].max, 255].min

    max_c = [r,g,b].max
    min_c = [r,g,b].min
    avg = (r+g+b)/3
    spread = max_c - min_c
    puts "HYBRID CRAYON: RGB(#{r},#{g},#{b})    |   SPREAD: #{spread} |  AVERAGE: #{avg}"
    return 16 if spread <= 20 && avg <= 5
    #if spread <= 20 && avg > 5
    if avg > 240 && spread > 5 && spread <= 20
        r6 = (r * 5 + 127) / 255
        g6 = (g * 5 + 127) / 255
        b6 = (b * 5 + 127) / 255
        return 16 + 36 * r6 + 6 * g6 +b6

        #gray_val = avg
        #gray_val = 8 if gray_val < 8
        #gray_val = 238 if gray_val > 238
        #return 232 + (gray_val - 8)/10
        #return 232 + (gray_val -8) * 23 / 247
    end

    #grey detection
    if spread <= 20 && avg > 5
        gray_val = avg
        gray_val = 8 if gray_val < 8
        gray_val = 238 if gray_val > 238
        #return 232 + (gray_val - 8)/10
        #return 
        idx = 232 + ((gray_val -8) * 23 / 247)
        return [idx, 255].min
    end

    
    
    #to preserve tint, give to gagbo
    #if avg > 240 && spread > 5
        #puts "HYBRID CRAYON GIVES TO GAGBO: "
        #hex = rgb2hex(r,g,b)
        #gagbo_index, rgb_hex = rgb2short(hex)
        #return gagbo_index#rgb2short(rgb2hex(r,g,b))
    #end


    r6 = (r * 5 + 127) / 255
    g6 = (g * 5 + 127) / 255
    b6 = (b * 5 + 127) / 255
    #return 
    16 + 36 * r6 + 6 * g6 +b6
end



def crayon_adaptive_rgb_to_index(r,g,b)
    r = [[r, 0].max, 255].min
    g = [[g, 0].max, 255].min
    b = [[b, 0].max, 255].min

    max_c = [r,g,b].max
    min_c = [r,g,b].min
    avg = (r+g+b)/3
    
    spread = max_c - min_c
    puts "ADAPTIVE CRAYON: RGB(#{r},#{g},#{b})    |   SPREAD: #{spread} |  AVERAGE: #{avg}"
    if spread <= (avg < 30 ? 10: (avg > 255 ? 8: 20))
    # go to grey scale
    #if max_c - min_c <= 20 && avg > 5
        gray_val = avg
        gray_val = 8 if gray_val < 8
        gray_val = 238 if gray_val > 238
        return 232 + (gray_val - 8)/10
    end


    r6 = (r * 5 + 127) / 255
    g6 = (g * 5 + 127) / 255
    b6 = (b * 5 + 127) / 255
    return 16 + 36 * r6 + 6 * g6 +b6
end


def crayon3_rgb_to_index(r,g,b)
    r = [[r, 0].max, 255].min
    g = [[g, 0].max, 255].min
    b = [[b, 0].max, 255].min

    max_c = [r,g,b].max
    min_c = [r,g,b].min
    avg = (r+g+b)/3
    spread = max_c - min_c
    puts "FIX IT CRAYON: RGB(#{r},#{g},#{b})    |   SPREAD: #{spread} |  AVERAGE: #{avg}"

    if spread <= 20 && avg > 5
        gray_val = avg
        gray_val = 8 if gray_val < 8
        gray_val = 238 if gray_val > 238
        return 232 + ((gray_val - 8) * 23 / 247)#/10
    end


    r6 = (r * 5 + 127) / 255
    g6 = (g * 5 + 127) / 255
    b6 = (b * 5 + 127) / 255
    return 16 + 36 * r6 + 6 * g6 +b6
end


def crayon2_rounding_rgb_to_index(r,g,b)
    r = [[r, 0].max, 255].min
    g = [[g, 0].max, 255].min
    b = [[b, 0].max, 255].min

    max_c = [r,g,b].max
    min_c = [r,g,b].min
    avg = (r+g+b)/3.0
    spread = max_c - min_c
    puts "ROUND CRAYON: RGB(#{r},#{g},#{b})    |   SPREAD: #{spread} |  AVERAGE: #{avg}"
    if spread <= 20 && avg > 5
        gray_val = avg
        gray_val = 8 if gray_val < 8
        gray_val = 238 if gray_val > 238
        return 232 + ((gray_val - 8) * 23 / 247.0).round#/10
    end


    r6 = (r * 5 + 127) / 255
    g6 = (g * 5 + 127) / 255
    b6 = (b * 5 + 127) / 255
    return 16 + 36 * r6 + 6 * g6 +b6
end

def crayon3_rgb_from_index(idx)
    if idx >= 232 #Grey scale
        val = 8 + ((idx - 232) * 247 + 23) / 23#10
        return [val, val, val]
    elsif idx >= 16
        idx -= 16
        #i = idx - 16
        #steps = [0, 95, 135, 175, 215, 255]
        r6 = idx/36
        g6 = (idx/6) % 6
        b6 = idx % 6
        #return [steps[r6], steps[g6], steps[b6]]
        r = (r6 * 255) / 5
        g = (g6 * 255) / 5
        b = (b6 * 255) / 5
        return [r,g,b]
    end
    return -1,-1,-1
end


def crayon2_rounding_rgb_from_index(idx)
    if idx >= 232 #Grey scale
        val = 8 + ((idx - 232) * 247 + 12) / 23 #* 10
        return [val, val, val]
    elsif idx >= 16
        idx -= 16
        #i = idx - 16
        #steps = [0, 95, 135, 175, 215, 255]
        r6 = idx/36
        g6 = (idx/6) % 6
        b6 = idx % 6
        #return [steps[r6], steps[g6], steps[b6]]
        r = (r6 * 255) / 5
        g = (g6 * 255) / 5
        b = (b6 * 255) / 5
        return [r,g,b]
    end
    return [-1,-1,-1]
end


def crayon2_rgb_from_index(idx)
    if idx >= 232 #Grey scale
        val = 8 + (idx - 232) * 10
        return [val, val, val]
    elsif idx >= 16
        idx -= 16
        #i = idx - 16
        #steps = [0, 95, 135, 175, 215, 255]
        r6 = idx/36
        g6 = (idx/6) % 6
        b6 = idx % 6
        #return [steps[r6], steps[g6], steps[b6]]
        r = (r6 * 255) / 5
        g = (g6 * 255) / 5
        b = (b6 * 255) / 5
        return [r,g,b]
    end
    return [-1,-1,-1]
end

def test_cases
    test_colors = [
#=begin
		[100, 100, 101], #Near Gray (1 diff)
		[100, 100, 105], #Near gray (5 Diff)
		[100, 100, 110], # Near gray(10 diff - boundary)
		[128, 128, 128], #Perfect gray
		[100, 100, 115], #Cool gray
		[180, 170, 160], #Warm gray
		[140, 135, 145], #Purple gray
		[75, 80, 70], #Olive-gray
		[0, 0, 1], #Almost black
		[254, 254, 255], #Almost white
		#[0, 255, 0], #Pure green
		[0, 128, 0], #Mid green
		[0, 128, 128], #Teal
		[139, 69, 19], #Brown
		[150, 140, 150],
		[200, 210, 200],
		[0, 0, 8],
		[5, 0, 0],
		[8, 8, 0],
		[248, 255, 248],
		[250, 242, 250],
		[120, 128, 120],
		[160, 152, 160],
		[180, 180, 169],
		[245, 255, 245],
		[8, 8, 8],
		[12, 12, 12],
		[100, 100,115],
		[6, 6, 6],
		#[255, 0, 0],
		[0, 128, 255],
		#[200, 50, 100],
		#[100, 200, 50],
		[100, 90, 80],
		[200, 185, 180],
		[50, 60, 70],
		[130, 120, 110],
		[3, 0, 5],
		[5, 5, 4],
		[0, 4, 0],
		[10, 10, 10],
		[50, 50, 50],
		[200, 200, 200],
		[0, 0, 0],
		[255, 255, 255],
		#[255, 0, 0],
		#[0, 255, 0],
		#[0, 0, 255],
		[128, 128, 128],
		#[255, 255, 0],
		#[255, 0, 255],
		#[0, 255, 255],
		[0,0,0],
		[100, 100, 125],
		[50,70,50],
		[200,175,200],
#=end
        #TO knock old crayon off
        [255,250,240],
        [255,240,245],
        [250,255,245],
        [245,245,255],
        [255, 248, 220],
        [100, 100, 121],
        [150,150,171],
        [80,80,101],
        [120,100,120],
        [100,120,100],
        [110,90,110],
        [6,6,6],
        [7,7,7],
        [4,4,6],
        [180,160,200],
        [200,175,225],
        [100,75,125],
        [237,237,237],
        [239,239,239],
        [9,9,9],
        [0,180,90],
		[70,40,10], #CLUT doesn't do well in the cube gap zone (0-95), neither does 2nd crayon or the others
		[60,80,90],
		[80,40,80],
		[40,60,40],
		[90,60,30],

		#[251, 241, 231],
    ]

    puts "="*50
    puts "TESTING RGB-256 COLOR CONVERSION"
    puts "="*50

    test_colors.each do |r,g,b|
        gchalk_index = gchalk_rgb_to_ansi256(r,g,b)
        #cr,cg,cb = crayon2_rgb_from_index(crayon_index)#rgb2hex(r,g,b)
        #gchalk_hex = rgb2hex(cr,cg,cb)

        adaptive_index = crayon_adaptive_rgb_to_index(r,g,b)
        hybrid_index = hybrid_rgb_to_index(r,g,b)

        crayon_index = crayon2_rgb_to_index(r,g,b)
        cr,cg,cb = crayon2_rgb_from_index(crayon_index)#rgb2hex(r,g,b)
        crayon_hex = rgb2hex(cr,cg,cb)

        crayon_fix_index = crayon3_rgb_to_index(r,g,b)
        cr,cg,cb = crayon3_rgb_from_index(crayon_index)#rgb2hex(r,g,b)
        crayon_fix_hex = rgb2hex(cr,cg,cb)

        crayon_round_index = crayon2_rounding_rgb_to_index(r,g,b)
        cr,cg,cb = crayon2_rounding_rgb_from_index(crayon_index)#rgb2hex(r,g,b)
        crayon_round_hex = rgb2hex(cr,cg,cb)
        
        true_color_hex = rgb2hex(r,g,b)
        #r,g,b = arg.split(',').map(&:to_i)
        #r,g,b = short2rgb(arg)
        hex = rgb2hex(r,g,b)
        gagbo_index, rgb_hex = rgb2short(hex)
        print "RGB(#{r},#{g},#{b})\n"
        print " TRUECOLOR: #{true_color_hex}".ljust(35)  + "\033[48;2;#{r};#{g};#{b}m      \033[0m\n"
        print "GAGBO CLUT: #{gagbo_index} (#{rgb_hex})".ljust(35) + "\033[48;5;#{gagbo_index}m      \033[0m\n"
        print "    GCHALK: #{gchalk_index} ".ljust(35) + "\033[48;5;#{gchalk_index}m      \033[0m\n"
        print "HYBRID CRAYON: #{gchalk_index} ".ljust(35) + "\033[48;5;#{gchalk_index}m      \033[0m\n"
        print "ADAPTIVE CRAYON: #{adaptive_index} ".ljust(35) + "\033[48;5;#{adaptive_index}m      \033[0m\n"
        print "2nd OLD CRAYON: #{crayon_index} (#{crayon_hex})".ljust(35) + "\033[48;5;#{crayon_index}m      \033[0m\n"
        print "CRAYON TRY FIX: #{crayon_fix_index} (#{crayon_fix_hex})".ljust(35) + "\033[48;5;#{crayon_fix_index}m      \033[0m\n"
        print "CRAYON ROUNDING: #{crayon_round_index} (#{crayon_round_hex})".ljust(35) + "\033[48;5;#{crayon_round_index}m      \033[0m\n\n"
    end
end

test_cases
# ==================================
# MAIN
#===================================

=begin
if __FILE__ == $PROGRAM_NAME
    require 'minitest/autorun' if ENV['TEST']
    if ARGV.empty?
        print_all
        exit 
    end

    arg = ARGV[0]

    if arg =~ /^\d+$/ && arg.to_i < 256
        rgb = short2rgb(arg)
        print "xterm color \033[38;5;#{arg}m#{arg}\033[0m -> RGB exact "
        print "\033[38;5;#{arg}m#{rgb}\033[0m\033[0m\n"
    elsif arg =~ /^\d+,\d+,\d+$/
        r,g,b = arg.split(',').map(&:to_i)
        #r,g,b = short2rgb(arg)
        hex = rgb2hex(r,g,b)
        index, rgb_hex = rgb2short(hex)
        print "RGB(#{r},#{g},#{b}) \033[48;2;#{r};#{g};#{b}m      \033[0m"
        print "-> xterm color approx #{index} (#{rgb_hex})"
        print "\033[48;5;#{index}m      \033[0m\n"
    else
        arg_rgb = hex2rgb(arg)
        short_legacy, rgb_legacy = rgb2short_legacy(arg)
        short, rgb = rgb2short(arg)
        print "(LEGACY) RGB #{arg} \033[38;2;#{arg_rgb[0]};#{arg_rgb[1]};#{arg_rgb[2]}m(TRUECOLOR) \033[0m"
        print "-> xterm color approx "
        print "\033[38;5;#{short_legacy}m#{short_legacy} (#{rgb_legacy})\033[0m\n"
        
        print "RGB #{arg} \033[38;2;#{arg_rgb[0]};#{arg_rgb[1]};#{arg_rgb[2]}m(TRUECOLOR) \033[0m"
        print "-> xterm color approx "
        print "\033[38;5;#{short}m#{short} (#{rgb})\033[0m\n"
    end
end
=end

