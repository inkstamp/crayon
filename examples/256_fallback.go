package main

import (
	"fmt"
	"math"
)

func main(){
	//crayon is pretty much accurate when spread is 18 (though it losses more grey to the cube)
    //18,19,20,21 = 4 spreads
	// ((spread - start_spread)/ total_number_of_spreads) give how far it is from the start to end of the transition zone
	//OR blend_factor = (current_spread - start_spread)/(end_spread - start_spread)
    //the spread should be 21 instead of 20 to catch more greys (though it decrease its accuracy)
	/*
	IF (spread BETWEEN 18 AND 22):
	  #boundary zone - Use both
	  crayon_result = Crayon_index(grayscale)
	  clut_result = CLUT_index(tinted)
	  
	 #Blend based on how close to boundary
	 blend_factor = (spread - 18)/4
	 IF blend_factor < 0.3:
	   USE crayon_result
	 ELSE IF blend_factor > 0.7;
	   USE clut_result
	 ELSE:
	   USE whichever has a better match
	  */
	testCases := [][]int {
		{100, 100, 101}, //Near Gray (1 diff)
		{100, 100, 105}, //Near gray (5 Diff)
		{100, 100, 110}, // Near gray(10 diff - boundary)
		{128, 128, 128}, //Perfect gray
		{100, 100, 115}, //Cool gray
		{180, 170, 160}, //Warm gray
		{140, 135, 145}, //Purple gray
		{75, 80, 70}, //Olive-gray
		{0, 0, 1}, //Almost black
		{254, 254, 255}, //Almost white
		{0, 255, 0}, //Pure green
		{0, 128, 0}, //Mid green
		{0, 128, 128}, //Teal
		{139, 69, 19}, //Brown
		{150, 140, 150},
		{200, 210, 200},
		{0, 0, 8},
		{5, 0, 0},
		{8, 8, 0},
		{248, 255, 248},
		{250, 242, 250},
		{120, 128, 120},
		{160, 152, 160},
		{180, 180, 169},
		{245, 255, 245},
		{8, 8, 8},
		{12, 12, 12},
		{100, 100,115},
		{6, 6, 6},
		{255, 0, 0},
		{0, 128, 255},
		//{200, 50, 100},
		{100, 200, 50},
		{100, 90, 80},
		{200, 185, 180},
		{50, 60, 70},
		{130, 120, 110},
		{3, 0, 5},
		{5, 5, 4},
		{0, 4, 0},
		{10, 10, 10},
		{50, 50, 50},
		{200, 200, 200},
		{0, 0, 0},
		{255, 255, 255},
		{255, 0, 0},
		{0, 255, 0},
		{0, 0, 255},
		{128, 128, 128},
		{255, 255, 0},
		{255, 0, 255},
		{0, 255, 255},
		{0,0,0},
		{100, 100, 125},
		{50,70,50},
		{200,175,200},
		//Get CLUT strength and 2nd crayon weakness
		{200, 50, 100},
		{255,0,0},
		{0,255,0},
		{139,69,19},
		{160,133,45},
		{210,105,30},
		{205,133,63},
		{180,120,60},
		{150, 75,0},
		{180,0,0},
		{0,180,0},
		{0,0,180},
		{180,90,0},
		{90,0,180}, //CLUT has its strength in mid saturated colors
		{0,180,90},
		{70,40,10}, //CLUT doesn't do well in the cube gap zone (0-95), neither does 2nd crayon or the others
		{60,80,90},
		{80,40,80},
		{40,60,40},
		{90,60,30},

		{170,85,0},
		{85,170,0},
		{170,0,85},

		{40,30,50},
		{4,4,6},
		{255,250,240},
		{100,100,120},
		{100,100,121},
		{200,50,100},
		{200,175,200},
		//{255,250,240},
		//{255,240,245},
		//{250,255,245},
		//{245,245,255},
		//{255,248,220},
		//{251, 241, 231},

	}
	//RGB{  1,  1,  7} - RGB{  1,  1, 25} are dark blue but most considered 16/232
	//2nd Crayon was the most accurate of all but it just sends dark blue to grey


	fmt.Println("Testing RGB to 256-color conversion")

	for _, rgb := range testCases {
	//for r:=1; r<=255; r++ {
	//	for g:=1; g<=255; g++ {
	//		for b:=1; b<=255; b++ {
		r, g, b := rgb[0], rgb[1], rgb[2]

		//Get indexes from each library
		gchalkIdx := callGChalk(uint8(r), uint8(g), uint8(b))
		//oldCrayonIdx := callOldCrayon(r, g, b)
		secOldCrayonIdx := callSecOldCrayon(r, g, b)
		withClutIdx := rgbToIndex(r, g, b, builClut())
		hybridIdx := callHybrid(r,g,b)
		//thirdOldCrayonIdx := callThirdOldCrayon(r, g, b)
		//fourthOldCrayonIdx := callFourthOldCrayon(r, g, b)
		//newCrayonIdx := callNewCrayon(r, g, b)
		//termenvIdx := callTermenv(r, g, b)

		fmt.Printf("RGB{%3d,%3d,%3d}\n", r, g, b)
		fmt.Printf("       TRUECOLOR:     \033[48;2;%d;%d;%dm      \033[0m\n", r, g, b)
		fmt.Printf("          Hybrid: %3d %s\n", hybridIdx, colorBlock(hybridIdx))
		//fmt.Printf("      new crayon: %3d %s\n", newCrayonIdx, colorBlock(newCrayonIdx))
		fmt.Printf("       with CLUT: %3d %s\n", withClutIdx, colorBlock(withClutIdx))
		fmt.Printf("  2nd old crayon: %3d %s\n", secOldCrayonIdx, colorBlock(secOldCrayonIdx))
		fmt.Printf("          gchalk: %3d %s\n\n", gchalkIdx, colorBlock(int(gchalkIdx)))
		//fmt.Printf("      old crayon: %3d %s\n", oldCrayonIdx, colorBlock(oldCrayonIdx))
		//fmt.Printf("  2nd old crayon: %3d %s\n", secOldCrayonIdx, colorBlock(secOldCrayonIdx))
		//fmt.Printf("  3rd old crayon: %3d %s\n", thirdOldCrayonIdx, colorBlock(thirdOldCrayonIdx))
		//fmt.Printf("  4th old crayon: %3d %s\n\n", fourthOldCrayonIdx, colorBlock(fourthOldCrayonIdx))
		//fmt.Printf("      new crayon: %3d %s\n", newCrayonIdx, colorBlock(newCrayonIdx))
		//fmt.Printf("  termenv: %3d %s\n", termenvIdx, colorBlock(termenvIdx))
	}
//}
	//}
}



//func main(){
	//for 256, grey scale starts at 232
	//for idx := 232; idx <= 255; idx++ {
	//	greyVal := (idx - 232) * 255 / 23
	//	fmt.Printf("Index: %3d: RGB(%3d, %3d, %3d)\n", idx, greyVal, greyVal, greyVal)
	//}
//}

func colorBlock(idx int) string {
	return fmt.Sprintf("\033[48;5;%dm      \033[0m", idx)
}


//FOr HYBRID CLUT + 2nd CRAYON

// RGB to 256 palette fallback
func callHybrid(r, g, b int) int {

    //Find the maximum and minimum channel values
	//to compute the range, spread across RGB channels.
	//A small range means the color is close to neutral/grey.
	maxC := r 
	if g > maxC { maxC = g }
	if b > maxC { maxC = b }

	minC := r 
	if g < minC { minC = g }
	if b < minC { minC = b }
    
	//Average luminance of the color
	//Used to determine how dark the color is
	avg := (r + g + b ) / 3
	spread := maxC - minC
	fmt.Println("SPREAD: ", spread)
	fmt.Println("AVERAGE: ", avg)
	//if avg < 30 {
	//	return rgbToIndex(r, g, b, builClut())
	//}

	if avg > 240 {
		return rgbToIndex(r, g, b, builClut())
	}

	//if spread <= 10{
	//	return callSecOldCrayon(r,g,b)
	//} else 
	
	 if spread <= 20 && avg < 2{
		if avg < 2 {
		return callSecOldCrayon(r,g,b)
		}// else {
		return rgbToIndex(r,g,b, builClut())
		//}
	} else if spread  >= 30 {
		//CLUT Doesnt do well with a 
		return rgbToIndex(r, g, b, builClut())
	} else if spread >= 22 {
		return rgbToIndex(r, g, b, builClut())
	} else {
		blend := float64(spread - 20)/ 2.0
		fmt.Println("BLEND: ", blend)
		crayon_idx := callSecOldCrayon(r,g,b)
		clut_idx := rgbToIndex(r, g, b, builClut())
		clut := builClut()

		if blend < 0.3{
			return crayon_idx
		} else if blend > 0.7 {
			return clut_idx
		} else {
			crayon_rgb := clut[crayon_idx]//rgbToIndex(r, g, b, builClut())
			clut_rgb := clut[clut_idx]
			crayon_bright := (crayon_rgb[0] + crayon_rgb[1] + crayon_rgb[2]) / 3
			clut_bright := (clut_rgb[0]+clut_rgb[1]+clut_rgb[2])/3
			if abs(avg - crayon_bright) < abs(avg - clut_bright){
				return crayon_idx
			} else {
				return clut_idx
			}

		}
	}
}


func callGChalk(red uint8, green uint8, blue uint8) uint8 {
	// Originally from // From https://github.com/Qix-/color-convert/blob/3f0e0d4e92e235796ccb17f6e85c72094a651f49/conversions.js

	// We use the extended greyscale palette here, with the exception of
	// black and white. normal palette only has 4 greyscale shades.
	if red == green && green == blue {
		if red < 8 {
			return 16
		}

		if red > 248 {
			return 231
		}

		return uint8(math.Round(((float64(red)-8)/247)*24)) + 232
	}

	return 16 +
		uint8(
			(36*math.Round(float64(red)/255*5))+
				(6*math.Round(float64(green)/255*5))+
				math.Round(float64(blue)/255*5))
}


//=========================
// CRAYON SECTION
//========================

//Old crayon doesn;t detect all greys. Grey catching is the priority as the cube doesnt handle them well.
//RGB(75,80,70): old crayon gives greenish tint, which isn't visually accurate. Proper grey detection would have saved the day
//RGB(180,170,160): old crayon gives pinkish which is questionable too. 

func abs(x int) int {
	if x < 0 {
		return -x
	}
	return x
}

// RGB to 256 palette fallback
func callOldCrayon(r, g, b int) int {
    r6 := (r * 5 + 127) / 255
	g6 := (g * 5 + 127) / 255
	b6 := (b * 5 + 127)/ 255
	//cubeIndex := 16 + 36*r6 + 6*g6 +b6


  //check if it's close enough to gray
  if abs(r-g) < 10 && abs(g-b) < 10 && abs(g-b) < 10 {
  	avg := (r + g + b) / 3
  	if avg < 8 {
  		avg = 8
  	}
  	if avg > 238 {
  		avg = 238
  	}
  	return  232 + (avg-8)/10
  }	
    //fmt.Printf("RGB TO INDEX FROM COLOR HELPERS CODE (NOT TEST):  RGB=(%d,%d,%d)  | 256 = %d\n", r, g, b, 16 + 36*r6 + 6*g6 +b6)
	return 16 + 36*r6 + 6*g6 +b6

}

// RGB to 256 palette fallback
func callSecOldCrayon(r, g, b int) int {

/*	if r== g && g == b {
		if r < 8 {
			return 16
		}

		if r > 248 {
			return 231
		}

		return int(math.Round(((float64(r)-8)/247)*24) )+ 232
	}*/
    //Find the maximum and minimum channel values
	//to compute the range, spread across RGB channels.
	//A small range means the color is close to neutral/grey.
	maxC := r 
	if g > maxC { maxC = g }
	if b > maxC { maxC = b }

	minC := r 
	if g < minC { minC = g }
	if b < minC { minC = b }
    
	//Average luminance of the color
	//Used to determine how dark the color is
	avg := (r + g + b ) / 3
    
	//====== GRAYSCALE RAMP ROUTING =========
	//Route to the 24-step grayscale ramp if 
	// - maxC-minC <= 20: The cube is too coarse for neutral tones
	//and introduces visible color casts such as pinkish, greenish, etc.
	//So the threshold was made wide enough (20)
	// - avg > 5:  it allows dark grays to correctly hit the ramp, whiles true or near blacks passes over (0, 0, 8)
	if maxC - minC <= 20 && avg > 5 {
		//Clamp avg to the valid grayscale ramp
		//Starts at RGB(8,8,8) and ends at RGB(238,238,238).
	if avg < 8 {
  		avg = 8
  	}
  	if avg > 238 {
  		avg = 238
  	}
	//Tries to map avg to grayscale ramp index 232-255
  	return  232 + (avg-8)/10
	//return  232 + ((avg-8)*23/247)
  }	



  //====== COLOR CUBE ROUTING ======
  // for colors where the channel spread exceeds 20.
    r6 := (r * 5 + 127) / 255
	g6 := (g * 5 + 127) / 255
	b6 := (b * 5 + 127)/ 255
    //fmt.Printf("RGB TO INDEX FROM COLOR HELPERS CODE (NOT TEST):  RGB=(%d,%d,%d)  | 256 = %d\n", r, g, b, 16 + 36*r6 + 6*g6 +b6)
	return 16 + 36*r6 + 6*g6 +b6

}



func max(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

// RGB to 256 palette fallback
func callThirdOldCrayon(r, g, b int) int {
    //r6 := (r * 5 + 127) / 255
	//g6 := (g * 5 + 127) / 255
	//b6 := (b * 5 + 127)/ 255
	//cubeIndex := 16 + 36*r6 + 6*g6 +b6
	maxC := max(r, max(g, b))
	//maxC := r 
	//if g > maxC { maxC = g }
	//if b > maxC { maxC = b }
	minC := min(r, min(g, b))

	//minC := r 
	//if g < minC { minC = g }
	//if b < minC { minC = b }

	avg := (r + g + b ) / 3
	spread := maxC - minC

	if spread < 15 {
  //check if it's close enough to gray
  //if abs(r-g) < 10 && abs(g-b) < 10 {
  	//avg := (r + g + b) / 3
    //if avg > 245 {
	//	return 255
	//}
	grayVal := avg

	if grayVal < 8 {
  		grayVal = 8
  	}
  	if grayVal > 247 {
  		grayVal = 247
  	}
  	return  232 + ((grayVal-8)*23/247)
  }	
   //cube mapping for colors
    r6 := (r * 5 + 127) / 255
	g6 := (g * 5 + 127) / 255
	b6 := (b * 5 + 127)/ 255
    //fmt.Printf("RGB TO INDEX FROM COLOR HELPERS CODE (NOT TEST):  RGB=(%d,%d,%d)  | 256 = %d\n", r, g, b, 16 + 36*r6 + 6*g6 +b6)
	return 16 + 36*r6 + 6*g6 +b6

}




// RGB to 256 palette fallback
func callFourthOldCrayon(r, g, b int) int {
    //r6 := (r * 5 + 127) / 255
	//g6 := (g * 5 + 127) / 255
	//b6 := (b * 5 + 127)/ 255
	//cubeIndex := 16 + 36*r6 + 6*g6 +b6
	maxC := r 
	if g > maxC { maxC = g }
	if b > maxC { maxC = b }

	minC := r 
	if g < minC { minC = g }
	if b < minC { minC = b }

	avg := (r + g + b ) / 3

	if maxC - minC < 15 && avg > 15 {
  //check if it's close enough to gray
  //if abs(r-g) < 10 && abs(g-b) < 10 {
  	//avg := (r + g + b) / 3
    if avg > 245 {
		return 255
	}

	//if avg < 8 {
  	//	avg = 8
  	//}
  	//if avg > 238 {
  	//	avg = 238
  	//}
  	//return  232 + (avg-8)/10
	return  232 + ((avg-8) * 23 / 247)
  }	
    r6 := (r * 5 + 127) / 255
	g6 := (g * 5 + 127) / 255
	b6 := (b * 5 + 127)/ 255
    //fmt.Printf("RGB TO INDEX FROM COLOR HELPERS CODE (NOT TEST):  RGB=(%d,%d,%d)  | 256 = %d\n", r, g, b, 16 + 36*r6 + 6*g6 +b6)
	return 16 + 36*r6 + 6*g6 +b6

}




func callNewCrayon(r, g, b int) int {
	if r == g && g== b {
		return grayMapping(r)
	}

	weigthedSpread := (abs(r-g)*2 + abs(g-b)*2 + abs(r-b))/ 5

	avg := (r + g +b ) / 3
	threshold := 15
	if avg < 30 {
		threshold = 10
	} else if avg > 255 {
		threshold = 10
	}
	
	if weigthedSpread <= threshold {
		fmt.Println("WEIGHT SPREAD")
		return grayMapping(avg)
	}

	return cubeMapping(r, g, b)
}

func grayMapping(value int) int {
	if value < 8 {
		return 16
	}

	if value > 247/*247*/ {
		fmt.Println("VALUE IS: ", value)
		return 231
	}
	return 232 + int(math.Round(float64(value)-8)/247*24)
}


func cubeMapping(r, g, b int) int {
	r6 := int(math.Round(float64(r)/ 255 * 5))
	g6 := int(math.Round(float64(g)/ 255 * 5))
	b6 := int(math.Round(float64(b)/ 255 * 5))
	return 16 + 36*r6 + 6*g6 + b6
}

//CLUT COMPUTATION
func builClut() [256][3]int {
	var clut [256][3]int
	//basic := [16][3]int{
	//	  {0,0,0}, {128,0,0}, {0,128,0}, {128,128,0},
   //{0,0,128}, {128,0,128}, {0,128,128}, {192,192,192},
  //{128,128,128}, {255,0,0}, {0,255,0}, {255,255,0}, {0,0,255}, {255,0,255}, {0,255,255},{255,255,255},
	//}

	//for i:= 0; i < 16; i++ {
	//	clut[i] = basic[i]
	//}

    steps := []int {0,95,135,175,215,255}
	idx := 16
	for r:= 0; r< 6; r++{
		for g:= 0; g< 6; g++{
			for b:= 0; b< 6; b++{
				clut[idx] = [3]int{steps[r], steps[g], steps[b]}
				idx++
			}
		}
	}

	//Gray scal
	for i:=0; i < 24; i++{
		val := 8 + i * 10
		clut[232+i] = [3]int{val,val,val}
	}
	return clut
}

func rgbToIndex(r,g,b int, clut [256][3]int) int {
	bestIndex := 0
	bestDistance := float64(^uint(0) >> 1)
	for idx, rgb := range clut {
		dr := float64(r - rgb[0])
		dg := float64(g - rgb[1])
		db := float64(b - rgb[2])

		distance := dr*dr + dg*dg + db*db
		if distance < bestDistance{
			bestDistance = distance
			bestIndex = idx
		}
	}
	return bestIndex
}
