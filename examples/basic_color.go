
package main

import "github.com/phamio/crayon"

func main(){
  // Simple colored text
  crayon.Parse("[fg=blue]][Success] [fg=3]message [fg=#ffff00][copied][fg=rgb(255,255,0)][done][reset]").Println()
  crayon.Parse("[fg=red bold]Error: Something went wrong![reset]").Println()
  crayon.Parse("[fg=cyan italic]Info message[reset]").Println()

  // Background colors
  crayon.Parse("[bg=blue fg=white]White text on blue background[reset]").Println()
  crayon.Parse("[bg=lightgreen fg=black]Black text on light green[reset]").Println()

  // Hex colors (requires truecolor support)
  crayon.Parse("[fg=#FF5733]Orange hex color[reset]").Println()
  crayon.Parse("[bg=#3498db]Blue background[reset]").Println()

  // RGB colors
  crayon.Parse("[fg=rgb(255,105,180)]Hot pink text[reset]").Println()
  crayon.Parse("[bg=rgb(50,205,50)]Lime green background[reset]").Println()

  // 256-color palette
  crayon.Parse("[fg=214]Orange from 256-color palette[reset]").Println()
  crayon.Parse("[bg=196]Red background from palette[reset]").Println()

  // Combine styles
  crayon.Parse("[bold underline=single] Bold and underlined[reset]").Println()
  crayon.Parse("[italic dim] Dim italic text. [italic=reset dim=reset][strike]Strikethrough  text only[reset]").Println()
  crayon.Parse("[blink=slow hidden]Slow blinking hidden text[reset]").Println()

  // Reset specific attributes
  crayon.Parse("[bold fg=blue]Blue bold text. [bold=reset]No longer bold, but still blue. [fg=reset]No color, but other styles remain[reset]").Println()
}
