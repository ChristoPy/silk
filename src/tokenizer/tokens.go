package tokenizer

import "regexp"

func TokensAvailable() []TokenDef {
	return []TokenDef{
		TokenDef{
			name:    "Comment",
			pattern: regexp.MustCompile("^//.*"),
		},
		TokenDef{
			name:    "Skip",
			pattern: regexp.MustCompile("^\\s+"),
		},
		TokenDef{
			name:    "Number",
			pattern: regexp.MustCompile("^\\d+"),
		},
		TokenDef{
			name:    "String",
			pattern: regexp.MustCompile("^\"[^\"]*\""),
		},
		TokenDef{
			name:    "Const",
			pattern: regexp.MustCompile("^const"),
		},
		TokenDef{
			name:    "Let",
			pattern: regexp.MustCompile("^let"),
		},
		TokenDef{
			name:    "Function",
			pattern: regexp.MustCompile("^function"),
		},
		TokenDef{
			name:    "Return",
			pattern: regexp.MustCompile("^return"),
		},
		TokenDef{
			name:    "Boolean",
			pattern: regexp.MustCompile("^true"),
		},
		TokenDef{
			name:    "Boolean",
			pattern: regexp.MustCompile("^false"),
		},
		TokenDef{
			name:    "Import",
			pattern: regexp.MustCompile("^import"),
		},
		TokenDef{
			name:    "From",
			pattern: regexp.MustCompile("^from"),
		},
		TokenDef{
			name:    "Match",
			pattern: regexp.MustCompile("^match"),
		},
		TokenDef{
			name:    "Export",
			pattern: regexp.MustCompile("^export"),
		},
		TokenDef{
			name:    "Identifier",
			pattern: regexp.MustCompile("^[a-zA-Z_][a-zA-Z0-9_]*"),
		},
		TokenDef{
			name:    "Equals",
			pattern: regexp.MustCompile("^="),
		},
		TokenDef{
			name:    "LParen",
			pattern: regexp.MustCompile("^\\("),
		},
		TokenDef{
			name:    "RParen",
			pattern: regexp.MustCompile("^)"),
		},
		TokenDef{
			name:    "LBrace",
			pattern: regexp.MustCompile("^{"),
		},
		TokenDef{
			name:    "RBrace",
			pattern: regexp.MustCompile("^}"),
		},
		TokenDef{
			name:    "LBracket",
			pattern: regexp.MustCompile("^\\["),
		},
		TokenDef{
			name:    "RBracket",
			pattern: regexp.MustCompile("^]"),
		},
		TokenDef{
			name:    "Colon",
			pattern: regexp.MustCompile("^:"),
		},
		TokenDef{
			name:    "Comma",
			pattern: regexp.MustCompile("^,"),
		},
		TokenDef{
			name:    "Dot",
			pattern: regexp.MustCompile("^\\."),
		},
	}
}
