package tokenizer

import (
	"regexp"
)

type Tokenizer struct {
	code   string
	line   int
	cursor int
	column int
	eof    bool
	file   string
}

type TokenDef struct {
	name    string
	pattern *regexp.Regexp
}

type Token struct {
	name   string
	value  string
	line   int
	column int
}

var languageTokens = []TokenDef{
	{
		name:    "Comment",
		pattern: regexp.MustCompile("^//.*"),
	},
	{
		name:    "Skip",
		pattern: regexp.MustCompile(`^\s+`),
	},
	{
		name:    "Number",
		pattern: regexp.MustCompile(`^\d+`),
	},
	{
		name:    "String",
		pattern: regexp.MustCompile("^\"[^\"]*\""),
	},
	{
		name:    "Const",
		pattern: regexp.MustCompile("^const"),
	},
	{
		name:    "Let",
		pattern: regexp.MustCompile("^let"),
	},
	{
		name:    "Function",
		pattern: regexp.MustCompile("^function"),
	},
	{
		name:    "Return",
		pattern: regexp.MustCompile("^return"),
	},
	{
		name:    "Boolean",
		pattern: regexp.MustCompile("^true"),
	},
	{
		name:    "Boolean",
		pattern: regexp.MustCompile("^false"),
	},
	{
		name:    "Import",
		pattern: regexp.MustCompile("^import"),
	},
	{
		name:    "From",
		pattern: regexp.MustCompile("^from"),
	},
	{
		name:    "Match",
		pattern: regexp.MustCompile("^match"),
	},
	{
		name:    "Export",
		pattern: regexp.MustCompile("^export"),
	},
	{
		name:    "Identifier",
		pattern: regexp.MustCompile("^[a-zA-Z_][a-zA-Z0-9_]*"),
	},
	{
		name:    "Equals",
		pattern: regexp.MustCompile("^="),
	},
	{
		name:    "LParen",
		pattern: regexp.MustCompile(`^\(`),
	},
	{
		name:    "RParen",
		pattern: regexp.MustCompile(`^\)`),
	},
	{
		name:    "LBrace",
		pattern: regexp.MustCompile("^{"),
	},
	{
		name:    "RBrace",
		pattern: regexp.MustCompile("^}"),
	},
	{
		name:    "LBracket",
		pattern: regexp.MustCompile(`^\[`),
	},
	{
		name:    "RBracket",
		pattern: regexp.MustCompile("^]"),
	},
	{
		name:    "Colon",
		pattern: regexp.MustCompile("^:"),
	},
	{
		name:    "Comma",
		pattern: regexp.MustCompile("^,"),
	},
	{
		name:    "Dot",
		pattern: regexp.MustCompile(`^\.`),
	},
}

func GetToken(source string) (foundToken Token, found bool) {
	for _, tokenDef := range languageTokens {
		if tokenDef.pattern.MatchString(source) {
			foundToken = Token{
				name:   tokenDef.name,
				value:  source,
				line:   0,
				column: 0,
			}
			found = true
			break
		}
	}

	return foundToken, found
}
