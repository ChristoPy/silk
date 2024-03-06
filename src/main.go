package main

import (
	"fmt"
	"silk/src/tokenizer"
)

func main() {
	token, tokenFound := tokenizer.GetToken("?")
	if !tokenFound {
		fmt.Println("Token not found")
	}
	fmt.Println(token)
	// fmt.Println(tokenizer.GetToken("// oi"))
	// fmt.Println(tokenizer.GetToken("       "))
	// fmt.Println(tokenizer.GetToken("312331323"))
	// fmt.Println(tokenizer.GetToken("\"oi\""))
	// fmt.Println(tokenizer.GetToken("const"))
	// fmt.Println(tokenizer.GetToken("let"))
	// fmt.Println(tokenizer.GetToken("function"))
	// fmt.Println(tokenizer.GetToken("return"))
	// fmt.Println(tokenizer.GetToken("true"))
	// fmt.Println(tokenizer.GetToken("false"))
	// fmt.Println(tokenizer.GetToken("import"))
	// fmt.Println(tokenizer.GetToken("from"))
	// fmt.Println(tokenizer.GetToken("match"))
	// fmt.Println(tokenizer.GetToken("export"))
	// fmt.Println(tokenizer.GetToken("oi"))
	// fmt.Println(tokenizer.GetToken("name"))
	// fmt.Println(tokenizer.GetToken("("))
	// fmt.Println(tokenizer.GetToken(")"))
	// fmt.Println(tokenizer.GetToken("{"))
	// fmt.Println(tokenizer.GetToken("}"))
	// fmt.Println(tokenizer.GetToken("["))
	// fmt.Println(tokenizer.GetToken("]"))
	// fmt.Println(tokenizer.GetToken(":"))
	// fmt.Println(tokenizer.GetToken(","))
	// fmt.Println(tokenizer.GetToken("."))
	// fmt.Println(tokenizer.GetToken(""))
	// fmt.Println()
}
