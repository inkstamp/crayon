//go:build windows

package crayon

//This file is meant for windows only

import (
	"golang.org/x/sys/windows"
)

func init() {
	stdout := windows.Handle(windows.Stdout)
	var mode uint32
	if err := windows.GetConsoleMode(stdout, &mode); err != nil {
		//if it fails, just strip off colors
		return
	}

	//ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x004
	// ENABLE_PROCESSED_OUTPUT = 0x0001
	// ENABLE_WRAP_AT_EOL_OUTPUT = 0x0002
	windows.SetConsoleMode(stdout, mode|0x0004|0x0001|0x0002)
}
