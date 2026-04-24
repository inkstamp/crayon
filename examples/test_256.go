package main

import (
	"fmt"
	"strconv"
	"github.com/ph4mished/crayon"
)

//this is for finding the 256 color palette in comparison to its 16 ansi
func main(){
	for i:=1; i<=255; i++{
	   fmt.Print("NUM: ", i)
	    //crayon.Parse("[fg=" + strconv.Itoa(i) + "] COLOR[reset]  [bg=" + strconv.Itoa(i) + "]BACKGROUND[reset]").Println()
	    crayon.Parse("[fg=" + strconv.Itoa(i) + "] COLOR[reset]  [bg=" + strconv.Itoa(i) + "]   " + strconv.Itoa(i) + "  [reset]").Println()
	}
}
