package crayon

var ColorMap = map[string]string{
	// Foreground colors
	"fg=black":        "30",
	"fg=red":          "31",
	"fg=green":        "32",
	"fg=yellow":       "33",
	"fg=blue":         "34",
	"fg=magenta":      "35",
	"fg=cyan":         "36",
	"fg=white":        "37",
	"fg=darkgray":     "90",
	"fg=lred":     "91",
	"fg=lgreen":   "92",
	"fg=lyellow":  "93",
	"fg=lblue":    "94",
	"fg=lmagenta": "95",
	"fg=lcyan":    "96",
	"fg=lwhite":   "97",

	// Background colors
	"bg=black":        "40",
	"bg=red":          "41",
	"bg=green":        "42",
	"bg=yellow":       "43",
	"bg=blue":         "44",
	"bg=magenta":      "45",
	"bg=cyan":         "46",
	"bg=white":        "47",
	"bg=darkgray":     "100",
	"bg=lred":     "101",
	"bg=lgreen":   "102",
	"bg=lyellow":  "103",
	"bg=lblue":    "104",
	"bg=lmagenta": "105",
	"bg=lcyan":    "106",
	"bg=lwhite":   "107",
}

var ResetMap = map[string]string{
	//these are the reset colors for foreground and background colors
	"reset":           "0",  //reset all styles
	"fg=reset":        "39", //resets foreground colors
	"bg=reset":        "49", //reset background colors
	"bold=reset":      "22",
	"dim=reset":       "22",
	"italic=reset":    "23",
	"underline=reset": "24",
	"blink=reset":     "25",
	//"blinkfast=reset": "26",
	"reverse=reset": "27",
	"hidden=reset":  "28",
	"strike=reset":  "29",
}

var StyleMap = map[string]string{
	//styles
	"bold":             "1", //bold/bright
	"dim":              "2", //dim/faint
	"italic":           "3",
	"underline=single": "4", //52 is also single underline
	"blink=slow":       "5", //slow blink
	"blink=fast":       "6", //fast blink //Some platforms show no difference between slow and fast blink
	"reverse":          "7",
	"hidden":           "8",
	"strike":           "9", //strike-through,
	"underline=double": "21",
}
