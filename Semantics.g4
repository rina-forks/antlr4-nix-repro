grammar Semantics;

// borrowed from https://github.com/UQ-PAC/bil-to-boogie-translator/blob/main/src/main/antlr4/Semantics.g4

// See aslp/libASL/asl.ott for reference grammar Bap-ali-plugin/asli_lifer.ml may also be useful for
// visitors

stmt: assignment_stmt | call_stmt | conditional_stmt | loop_stmt;
stmts: OPEN_BRACKET (stmt (SCOLON stmt)*)? CLOSE_BRACKET;

stmt_lines: stmt* EOF;  // a convenient entry point for space-separated stmts, unused within this gramamr

assignment_stmt:
	'Stmt_Assign' OPEN_PAREN lexpr COMMA expr CLOSE_PAREN					# Assign
	| 'Stmt_ConstDecl' OPEN_PAREN type COMMA ident COMMA expr CLOSE_PAREN	# ConstDecl
	| 'Stmt_VarDecl' OPEN_PAREN type COMMA ident COMMA expr CLOSE_PAREN    # VarDecl
	| 'Stmt_VarDeclsNoInit' OPEN_PAREN type COMMA OPEN_BRACKET (ident (COMMA ident)*)? CLOSE_BRACKET CLOSE_PAREN  # VarDeclsNoInit
	| 'Stmt_Assert' OPEN_PAREN expr CLOSE_PAREN # Assert
	| 'Stmt_Throw' OPEN_PAREN message=ident+ CLOSE_PAREN # Throw;

call_stmt:
	'Stmt_TCall' OPEN_PAREN
		ident COMMA

		OPEN_BRACKET (targs (SCOLON targs)*)? CLOSE_BRACKET COMMA

		OPEN_BRACKET (expr (SCOLON expr)*)? CLOSE_BRACKET

		CLOSE_PAREN;

conditional_stmt:
	'Stmt_If' OPEN_PAREN expr COMMA
	  tcase=stmts COMMA
		OPEN_BRACKET CLOSE_BRACKET COMMA  // elseif chains are transformed away by aslp
		fcase=stmts CLOSE_PAREN
	# ConditionalStmt
;

loop_stmt:
  'Stmt_For' OPEN_PAREN ident COMMA start_index=expr COMMA direction COMMA stop_index=expr COMMA
    stmts CLOSE_PAREN
  #LoopStmt
;

type_register_slices:
	(COMMA OPEN_PAREN OPEN_BRACKET 'Slice_HiLo' OPEN_PAREN expr COMMA expr CLOSE_PAREN CLOSE_BRACKET COMMA ident CLOSE_PAREN)*;

type:
	'Type_Bits' OPEN_PAREN expr CLOSE_PAREN  # TypeBits
	| 'Type_Constructor("boolean")'            # TypeBoolean
	| 'Type_Constructor(' name=ident ')'       # TypeConstructor
	| 'Type_Register' OPEN_PAREN QUOTE width=integer QUOTE type_register_slices CLOSE_PAREN # TypeRegister;

lexpr:
	'LExpr_Var' OPEN_PAREN ident CLOSE_PAREN			# LExprVar
	| 'LExpr_Field' OPEN_PAREN lexpr COMMA ident CLOSE_PAREN		# LExprField
	| 'LExpr_Array' OPEN_PAREN (lexpr (COMMA expr)*)? CLOSE_PAREN	# LExprArray;

expr:
	'Expr_Var' OPEN_PAREN ident CLOSE_PAREN                                     # ExprVar
	| 'Expr_TApply' OPEN_PAREN ident COMMA
	    OPEN_BRACKET (targs (SCOLON targs)*)? CLOSE_BRACKET COMMA
	    OPEN_BRACKET (expr (SCOLON expr)*)? CLOSE_BRACKET
	    CLOSE_PAREN                                                             # ExprTApply
	| 'Expr_Slices' OPEN_PAREN expr COMMA
			OPEN_BRACKET slice_expr CLOSE_BRACKET
			CLOSE_PAREN										                                          # ExprSlices
	| 'Expr_Field' OPEN_PAREN expr COMMA ident CLOSE_PAREN                      # ExprField
	| 'Expr_Array' OPEN_PAREN base=expr (COMMA indices+=expr)* CLOSE_PAREN			# ExprArray
	| integer                                                                 	# ExprLitInt
	| bits                                                                      # ExprLitBits
	| OPEN_PAREN expr CLOSE_PAREN                                               # ExprParen
	// | 'Expr_LitHex' OPEN_PAREN QUOTE HEXDIGIT+ QUOTE CLOSE_PAREN		# ExprLitHex
	// | 'Expr_LitMask' OPEN_PAREN QUOTE BINARY QUOTE CLOSE_PAREN		# ExprLitMask
	// | 'Expr_LitString' OPEN_PAREN QUOTE ident QUOTE CLOSE_PAREN		# ExprLitString
;

direction:
  'Direction_Up' |
  'Direction_Down' ;

ident: QUOTE ID QUOTE;

integer: DECIMAL;
bits: BINARY;

targs: expr;

slice_expr: 'Slice_LoWd' OPEN_PAREN expr COMMA expr CLOSE_PAREN;

BINARY: SQUOTE [0-1]+ SQUOTE;
DECIMAL: [0-9]+;
ID: [a-zA-Z_][a-zA-Z0-9_.]*;

// Delimiters
OPEN_PAREN: '(';
CLOSE_PAREN: ')';
COMMA: ',';
OPEN_BRACKET: '[';
CLOSE_BRACKET: ']';
SQUOTE: '\'';
QUOTE: '"';
SCOLON: ';';

// Ignored
NEWLINE: ('\r\n' | '\n') -> skip;
WHITESPACE: ' '+ -> skip;
COMMENT: '//' ~[\r\n]* -> skip;
