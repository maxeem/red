Red/System [
	File: 	 %parser.reds
	Tabs:	 4
	Rights:  "Copyright (C) 2024 Red Foundation. All rights reserved."
	License: "BSD-3 - https://github.com/red/red/blob/master/BSD-3-License.txt"
]

#define VISITOR_FUNC(name) [name [visit-fn!]]

visitor!: alias struct! [
	VISITOR_FUNC(visit-if)
	VISITOR_FUNC(visit-case)
	VISITOR_FUNC(visit-switch)
	VISITOR_FUNC(visit-loop)
	VISITOR_FUNC(visit-while)
	VISITOR_FUNC(visit-until)
	VISITOR_FUNC(visit-func)
	VISITOR_FUNC(visit-break)
	VISITOR_FUNC(visit-continue)
	VISITOR_FUNC(visit-return)
	VISITOR_FUNC(visit-exit)
	VISITOR_FUNC(visit-fn-call)
	VISITOR_FUNC(visit-assign)
	VISITOR_FUNC(visit-bin-op)
	VISITOR_FUNC(visit-var)
	VISITOR_FUNC(visit-declare)
	VISITOR_FUNC(visit-array)
	VISITOR_FUNC(visit-not)
	VISITOR_FUNC(visit-size?)
	VISITOR_FUNC(visit-cast)
	VISITOR_FUNC(visit-literal)
	VISITOR_FUNC(visit-comment)
]

#define ACCEPT_FN_SPEC [self [int-ptr!] v [visitor!] data [int-ptr!] return: [int-ptr!]]
#define VISIT_FN_SPEC [node [int-ptr!] data [int-ptr!] return: [int-ptr!]]
#define KEYWORD_FN_SPEC [
	pc		[cell!]
	end		[cell!]
	expr	[ptr-ptr!]	;-- a pointer to receive the expr
	ctx		[context!]
	return: [cell!]
]

accept-fn!: alias function! [ACCEPT_FN_SPEC]
visit-fn!: alias function! [VISIT_FN_SPEC]
keyword-fn!: alias function! [KEYWORD_FN_SPEC]

#enum rst-op! [		;@@ order matters
	RST_OP_ADD
	RST_OP_SUB
	RST_OP_MUL
	RST_OP_DIV
	RST_OP_MOD
	RST_OP_REM
	RST_OP_AND
	RST_OP_OR
	RST_OP_XOR
	RST_OP_SHL
	RST_OP_SAR
	RST_OP_SHR
	RST_OP_EQ
	RST_OP_NE
	RST_OP_LT
	RST_OP_LTEQ
	RST_OP_GT
	RST_OP_GTEQ
	RST_OP_SIZE
	;-- sugar ops
	RST_MIXED_EQ	;-- e.g. compare int with uint
	RST_MIXED_NE
	RST_MIXED_LT
	RST_MIXED_LTEQ
]

#enum rst-node-type! [
	RST_VOID
	RST_LOGIC
	RST_INT
	RST_BYTE
	RST_FLOAT
	RST_NULL
	RST_C_STR
	RST_BINARY
	RST_LIT_ARRAY		;-- literal array
	RST_DECLARE
	RST_PTR
	RST_BYTE_PTR
	RST_INT_PTR
	RST_BIN_OP
	RST_NOT
	RST_SIZEOF
	RST_CAST
	RST_FN_CALL
	RST_VAR
	RST_IF
	RST_SWITCH
	RST_CASE
	RST_ANY
	RST_ALL
	RST_ASSIGN
	RST_EXPR_END		;-- end marker of expr types
	RST_CONTEXT
	RST_FUNC
	RST_VAR_DECL
	RST_WHILE
	RST_LOOP
	RST_UNTIL
	RST_BREAK
	RST_CONTINUE
	RST_THROW
	RST_CATCH
	RST_RETURN
	RST_EXIT
	RST_COMMENT
]

#enum fn-attr! [
	FN_CC_INTERNAL:		0
	FN_CC_STDCALL:		1
	FN_CC_CDECL:		2
	FN_INFIX:			4
	FN_CALLBACK:		8
	FN_VARIADIC:		10h
	FN_TYPED:			20h
	FN_CUSTOM:			40h
	FN_CATCH:			80h
	FN_EXTERN:			0100h
]

#enum rst-node-flag! [
	RST_AS_KEEP:	1
	RST_VAR_LOCAL:	2	;-- local variable
	RST_VAR_PARAM:	4	;-- var-decl! is a parameter
	RST_FN_CTX:		8
	RST_INFIX_FN:	10h
	RST_INFIX_OP:	20h
	RST_IMPORT_FN:	40h
	RST_SIZE_TYPE:	80h
]

#define SET_NODE_TYPE(node type) [node/header: type]
#define ADD_NODE_FLAGS(node flags) [node/header: node/header or (flags << 8)]
#define NODE_TYPE(node) (node/header and FFh)
#define NODE_FLAGS(node) (node/header >>> 8)

;-- fn-type! /header bits: 8 - 15 opcode, 16 - 31: attributes
#define FN_OPCODE(f) (f/header >>> 8 and FFh)
#define FN_ATTRS(f) (f/header >>> 16)
#define ADD_FN_ATTRS(f attrs) [f/header: f/header or (attrs << 16)]
#define SET_FN_OPCODE(f op) [f/header: f/header and FFFF00FFh or (op << 8)]

#define RST_NODE_FIELDS(self) [	;-- RST: R/S Syntax Tree
	header	[integer!]		;-- rst-node-type! bits: 0 - 7
	next	[self]
	token	[cell!]
]

#define RST_STMT_FIELDS(self) [
	RST_NODE_FIELDS(self)
	accept	[accept-fn!]
]

#define RST_EXPR_FIELDS(self) [
	RST_NODE_FIELDS(self)
	accept		[accept-fn!]
	cast-type	[rst-type!]
	type		[rst-type!]
]

rst-node!: alias struct! [
	RST_NODE_FIELDS(rst-node!)
]

rst-stmt!: alias struct! [
	RST_STMT_FIELDS(rst-stmt!)
]

rst-expr!: alias struct! [
	RST_EXPR_FIELDS(rst-expr!)
]

ssa-var!: alias struct! [
	index		[integer!]
	value		[instr!]
	loop-bset	[integer!]	;-- loop bitset, var used in loops, can encode 32 loops
	extra-bset	[ptr-array!]
]

#define LOCAL_VAR?(var) (NODE_FLAGS(var) and RST_VAR_LOCAL <> 0)

var-decl!: alias struct! [	;-- variable declaration
	RST_NODE_FIELDS(var-decl!)
	typeref		[red-block!]
	type		[rst-type!]
	init		[rst-expr!]	;-- init expression or parameter idx
	ssa			[ssa-var!]
	data-idx	[integer!]	;-- for global var, index in data section
]

variable!: alias struct! [
	RST_EXPR_FIELDS(variable!)
	decl		[var-decl!]
]

context!: alias struct! [
	RST_NODE_FIELDS(context!)
	parent		 [context!]
	child		 [context!]
	stmts		 [rst-stmt!]
	last-stmt	 [rst-stmt!]
	decls		 [int-ptr!]
	with-ns		 [vector!]
	ret-type	 [rst-type!]
	typecache	 [int-ptr!]
	n-ssa-vars	 [integer!]	;-- number of variable that written more than once
	n-loops		 [integer!]
	loop-stack	 [vector!]
	level		 [integer!]
	src-blk		 [red-block!]
	script		 [cell!]
	throw-error? [logic!]
]

fn!: alias struct! [
	RST_EXPR_FIELDS(fn!)
	parent		[context!]
	body		[red-block!]
	locals		[var-decl!]
	ir			[ir-fn!]
	cc			[call-conv!]
]

import-fn!: alias struct! [		;-- extends fn!
	RST_EXPR_FIELDS(fn!)
	parent		[context!]
	body		[red-block!]
	locals		[var-decl!]
	ir			[ir-fn!]
	cc			[call-conv!]
	import-name [cell!]
	import-lib	[cell!]
]

fn-call!: alias struct! [
	RST_EXPR_FIELDS(fn-call!)
	fn			[fn!]
	args		[rst-expr!]
]

cast!: alias struct! [
	RST_EXPR_FIELDS(cast!)
	typeref		[cell!]
	expr		[rst-expr!]
]

declare!: alias struct! [
	RST_EXPR_FIELDS(declare!)
	typeref		[cell!]
]

assignment!: alias struct! [
	RST_EXPR_FIELDS(assignment!)
	target		[variable!]
	expr		[rst-expr!]
]

if!: alias struct! [
	RST_EXPR_FIELDS(rst-node!)
	cond		[rst-expr!]
	t-branch	[rst-stmt!]
	f-branch	[rst-stmt!]
	true-blk	[red-block!]
	false-blk	[red-block!]
]

case!: alias struct! [
	RST_EXPR_FIELDS(rst-node!)
	cases		[if!]
]

switch-case!: alias struct! [
	RST_NODE_FIELDS(switch-case!)
	expr		[rst-expr!]
	body		[rst-stmt!]
]

switch!: alias struct! [
	RST_EXPR_FIELDS(rst-node!)
	expr		[rst-expr!]
	cases		[switch-case!]
	defcase		[rst-stmt!]
]

while!: alias struct! [
	RST_STMT_FIELDS(rst-node!)
	loop-idx	[integer!]
	cond		[rst-stmt!]
	body		[rst-stmt!]
	cond-blk	[red-block!]
	body-blk	[red-block!]
]

return!: alias struct! [
	RST_STMT_FIELDS(rst-node!)
	expr		[rst-expr!]
]

exit!: alias struct! [
	RST_STMT_FIELDS(rst-node!)
]

continue!: alias struct! [
	RST_STMT_FIELDS(rst-node!)
]

break!: alias struct! [
	RST_STMT_FIELDS(rst-node!)
]

unary!: alias struct! [
	RST_EXPR_FIELDS(unary!)
	expr		[rst-expr!]
]

bin-op!: alias struct! [
	RST_EXPR_FIELDS(bin-op!)
	op			[int-ptr!]
	spec		[fn-type!]
	left		[rst-expr!]
	right		[rst-expr!]
]

literal!: alias struct! [
	RST_EXPR_FIELDS(literal!)
]

logic-literal!: alias struct! [
	RST_EXPR_FIELDS(literal!)
	value		[logic!]
]

int-literal!: alias struct! [
	RST_EXPR_FIELDS(int-literal!)
	value		[integer!]
]

float-literal!: alias struct! [
	RST_EXPR_FIELDS(float-literal!)
	value		[float!]
]

array-literal!: alias struct! [
	RST_EXPR_FIELDS(float-literal!)
	length		[integer!]
]

#define T_WORD?(v)  [TYPE_OF(v) = TYPE_WORD]
#define T_BLOCK?(v) [TYPE_OF(v) = TYPE_BLOCK]

parser: context [
	k_func:		symbol/make "func"
	k_function:	symbol/make "function"
	k_alias:	symbol/make "alias"
	k_context:	symbol/make "context"
	k_any:		symbol/make "any"
	k_all:		symbol/make "all"
	k_as:		symbol/make "as"
	k_declare:	symbol/make "declare"
	k_size?:	symbol/make "size?"
	k_not:		symbol/make "not"
	k_null:		symbol/make "null"
	k_if:		symbol/make "if"
	k_either:	symbol/make "either"
	k_while:	symbol/make "while"
	k_until:	symbol/make "until"
	k_loop:		symbol/make "loop"
	k_case:		symbol/make "case"
	k_switch:	symbol/make "switch"
	k_continue:	symbol/make "continue"
	k_break:	symbol/make "break"
	k_throw:	symbol/make "throw"
	k_catch:	symbol/make "catch"
	k_variadic:	symbol/make "variadic"
	k_stdcall:	symbol/make "stdcall"
	k_cdecl:	symbol/make "cdecl"
	k_infix:	symbol/make "infix"
	k_typed:	symbol/make "typed"
	k_custom:	symbol/make "custom"
	k_return:	symbol/make "return"
	k_exit:		symbol/make "exit"
	k_local:	symbol/make "local"
	k_assert:	symbol/make "assert"
	k_comment:	symbol/make "comment"
	k_with:		symbol/make "with"
	k_use:		symbol/make "use"
	k_true:		symbol/make "true"
	k_false:	symbol/make "false"
	k_default:	symbol/make "default"
	k_keep:		symbol/make "keep"

	k_+:			symbol/make "+"
	k_-:			symbol/make "-"
	k_=:			symbol/make "="
	k_>=:			symbol/make ">="
	k_>:			symbol/make ">"
	k_>>:			symbol/make ">>"
	k_>>>:			symbol/make ">>>"
	k_less:			symbol/make "<"
	k_less_eq:		symbol/make "<="
	k_not_eq:		symbol/make "<>"
	k_slash:		symbol/make "/"
	k_dbl_slash:	symbol/make "//"
	k_percent:		symbol/make "%"
	k_star:			symbol/make "*"	

	;-- issue directives
	k_import:		symbol/make "import"
	k_export:		symbol/make "export"
	k_syscall:		symbol/make "syscall"
	k_call:			symbol/make "call"
	k_get:			symbol/make "get"
	k_in:			symbol/make "in"
	k_enum:			symbol/make "enum"
	k_verbose:		symbol/make "verbose"
	k_u16:			symbol/make "u16"
	k_inline:		symbol/make "inline"
	k_script:		symbol/make "script"
	k_user-code:	symbol/make "user-code"
	k_typecheck:	symbol/make "typecheck"
	k_build-date:	symbol/make "build-date"

	keywords:  as int-ptr! 0
	infix-Ops: as int-ptr! 0

	init: does [
		keywords: hashmap/make 300
		infix-Ops: hashmap/make 100
		hashmap/put infix-Ops k_+			as int-ptr! RST_OP_ADD
		hashmap/put infix-Ops k_-			as int-ptr! RST_OP_SUB
		hashmap/put infix-Ops k_=			as int-ptr! RST_OP_EQ
		hashmap/put infix-Ops k_>=			as int-ptr! RST_OP_GTEQ
		hashmap/put infix-Ops k_>			as int-ptr! RST_OP_GT
		hashmap/put infix-Ops k_>>			as int-ptr! RST_OP_SAR
		hashmap/put infix-Ops k_>>>			as int-ptr! RST_OP_SHR
		hashmap/put infix-Ops k_less		as int-ptr! RST_OP_LT
		hashmap/put infix-Ops k_less_eq		as int-ptr! RST_OP_LTEQ
		hashmap/put infix-Ops k_not_eq		as int-ptr! RST_OP_NE
		hashmap/put infix-Ops k_slash		as int-ptr! RST_OP_DIV
		hashmap/put infix-Ops k_dbl_slash	as int-ptr! RST_OP_MOD
		hashmap/put infix-Ops k_percent		as int-ptr! RST_OP_REM
		hashmap/put infix-Ops k_star		as int-ptr! RST_OP_MUL

		hashmap/put keywords k_any		as int-ptr! :parse-any
        hashmap/put keywords k_all		as int-ptr! :parse-all
        hashmap/put keywords k_as		as int-ptr! :parse-as
        hashmap/put keywords k_declare	as int-ptr! :parse-declare
        hashmap/put keywords k_size?	as int-ptr! :parse-size?
        hashmap/put keywords k_not		as int-ptr! :parse-not
        hashmap/put keywords k_null		as int-ptr! :parse-null
        hashmap/put keywords k_if		as int-ptr! :parse-if
        hashmap/put keywords k_either	as int-ptr! :parse-if
        hashmap/put keywords k_while	as int-ptr! :parse-while
        hashmap/put keywords k_until	as int-ptr! :parse-until
        hashmap/put keywords k_loop		as int-ptr! :parse-loop
        hashmap/put keywords k_case		as int-ptr! :parse-case
        hashmap/put keywords k_switch	as int-ptr! :parse-switch
        hashmap/put keywords k_continue	as int-ptr! :parse-continue
        hashmap/put keywords k_break	as int-ptr! :parse-break
        hashmap/put keywords k_throw	as int-ptr! :parse-throw
        hashmap/put keywords k_catch	as int-ptr! :parse-catch
        hashmap/put keywords k_return	as int-ptr! :parse-return
        hashmap/put keywords k_exit		as int-ptr! :parse-exit
        hashmap/put keywords k_assert	as int-ptr! :parse-assert
        hashmap/put keywords k_comment	as int-ptr! :parse-comment
        hashmap/put keywords k_with		as int-ptr! :parse-with
        hashmap/put keywords k_use		as int-ptr! :parse-use
        hashmap/put keywords k_true		as int-ptr! :parse-logic
        hashmap/put keywords k_false	as int-ptr! :parse-logic
	]

	advance: func [
		pc		[cell!]
		end		[cell!]
		idx		[integer!]
		return: [cell!]
	][
		pc: pc + idx
		if pc >= end [
			throw-error [pc - 1 "EOF: expect mroe code"]
		]
		pc
	]

	advance-next: func [
		pc		[cell!]
		end		[cell!]
		return: [cell!]
	][
		pc: pc + 1
		if pc >= end [
			throw-error [pc - 1 "EOF: expect more code"]
		]
		pc
	]

	skip: func [
		pc		[cell!]
		end		[cell!]
		type	[integer!]
		return: [cell!]
	][
		while [
			all [pc < end TYPE_OF(pc) = TYPE]
		][
			pc: pc + 1
		]
		pc
	]

	expect: func [
		pc		[cell!]
		type	[integer!]
		return: [cell!]
	][
		if TYPE_OF(pc) <> type [
			throw-error [pc "Expect type:" type]
			halt
		]
		pc
	]

	expect-next: func [
		pc		[cell!]
		end		[cell!]
		type	[integer!]
		return: [cell!]
	][
		pc: pc + 1
		if pc >= end [throw-error [pc - 1 "EOF: expect more code"]]
		if TYPE_OF(pc) <> type [
			throw-error [pc "Expect type:" type]
			halt
		]
		pc
	]

	unreachable: func [pc [cell!]][
		throw-error [pc "Should not reach here!!!"]
	]

	make-param-types: func [
		ltype	[rst-type!]
		rtype	[rst-type!]
		return: [ptr-ptr!]
		/local
			pt	[ptr-ptr!]
			t2	[ptr-ptr!]
	][
		pt: as ptr-ptr! malloc 2 * size? int-ptr!
		pt/value: as int-ptr! ltype
		t2: pt + 1
		t2/value: as int-ptr! rtype
		pt
	]

	make-ctx: func [
		name	[cell!]
		parent	[context!]
		fn?		[logic!]
		return: [context!]
		/local
			ctx [context!]
	][
		ctx: as context! malloc size? context!
		ctx/token: name
		ctx/parent: parent
		ctx/stmts: as rst-stmt! malloc size? rst-stmt!	;-- stmt head
		ctx/last-stmt: ctx/stmts
		ctx/decls: hashmap/make either fn? [100][1000]
		ctx/loop-stack: vector/make size? integer! 32
		SET_NODE_TYPE(ctx RST_CONTEXT)
		if all [not fn? parent <> null][
			ctx/next: parent/child
			parent/child: ctx
		]
		ctx/src-blk: cur-blk
		ctx/script: script
		ctx/ret-type: type-system/void-type
		ctx/typecache: type-system/make-cache
		ctx/throw-error?: yes
		ctx
	]

	make-func: func [
		name	[cell!]
		parent	[context!]
		import? [logic!]
		return: [fn!]
		/local
			f	[fn!]
	][
		func_accept: func [ACCEPT_FN_SPEC][
			v/visit-func self data
		]
		f: as fn! either import? [malloc size? import-fn!][malloc size? fn!]
		f/token: name
		f/parent: parent
		f/accept: :func_accept
		SET_NODE_TYPE(f RST_FUNC)
		f
	]

	make-bin-op: func [
		op		[int-ptr!]
		left	[rst-expr!]
		right	[rst-expr!]
		pos		[cell!]
		return: [bin-op!]
		/local
			b	[bin-op!]
	][
		bin_accept: func [ACCEPT_FN_SPEC][
			v/visit-bin-op self data
		]
		b: as bin-op! malloc size? bin-op!
		b/token: pos
		b/op: op
		b/left: left
		b/right: right
		b/accept: :bin_accept
		SET_NODE_TYPE(b RST_BIN_OP)
		b
	]

	make-lit-array: func [
		pos		[cell!]
		return: [array-literal!]
		/local
			a	[array-literal!]
	][
		array_accept: func [ACCEPT_FN_SPEC][
			v/visit-literal self data
		]
		a: xmalloc(array-literal!)
		SET_NODE_TYPE(a RST_LIT_ARRAY)
		a/token: pos
		a/accept: :array_accept
		a/type: type-system/lit-array-type? pos
		a
	]

	make-int: func [
		pos		[cell!]
		return: [int-literal!]
		/local
			int [int-literal!]
			i	[red-integer!]
	][
		i: as red-integer! pos
		int_accept: func [ACCEPT_FN_SPEC][
			v/visit-literal self data
		]
		int: as int-literal! malloc size? int-literal!
		SET_NODE_TYPE(int RST_INT)
		int/token: pos
		int/value: i/value
		int/accept: :int_accept
		int/type: as rst-type! type-system/integer-type
		int
	]

	make-float: func [
		pos		[cell!]
		return: [float-literal!]
		/local
			f		[float-literal!]
			float	[red-float!]
	][
		float: as red-float! pos
		float_accept: func [ACCEPT_FN_SPEC][
			v/visit-literal self data
		]
		f: as float-literal! malloc size? float-literal!
		SET_NODE_TYPE(f RST_FLOAT)
		f/token: pos
		f/value: float/value
		f/accept: :float_accept
		f/type: as rst-type! type-system/float-type
		f
	]

	make-assignment: func [
		target	[var-decl!]
		expr	[rst-expr!]
		pos		[cell!]
		return: [assignment!]
		/local
			assign [assignment!]
	][
		assign_accept: func [ACCEPT_FN_SPEC][
			v/visit-assign self data
		]
		assign: as assignment! malloc size? assignment!
		SET_NODE_TYPE(assign RST_ASSIGN)
		assign/token: pos
		assign/target: make-variable target pos
		assign/expr: expr
		assign/accept: :assign_accept
		assign
	]

	make-var-decl: func [
		name	[cell!]
		typeref	[red-block!]
		return: [var-decl!]
		/local
			var [var-decl!]
	][
		var: as var-decl! malloc size? var-decl!
		SET_NODE_TYPE(var RST_VAR_DECL)
		var/token: name
		var/typeref: typeref
		var/data-idx: -1
		var
	]

	make-variable: func [
		decl	[var-decl!]
		pos		[cell!]
		return: [variable!]
		/local
			var [variable!]
	][
		var: as variable! malloc size? variable!
		SET_NODE_TYPE(var RST_VAR)
		var_accept: func [ACCEPT_FN_SPEC][
			v/visit-var self data
		]
		var/accept: :var_accept
		var/token: pos
		var/decl: decl
		var
	]

	parse-call: func [
		pc		[cell!]
		end		[cell!]
		fn		[fn!]
		out		[ptr-ptr!]
		ctx		[context!]
		return: [cell!]
		/local
			fc	[fn-call!]
			n	[integer!]
			ft	[fn-type!]
			pp	[ptr-value!]
			beg [rst-node! value]
			cur [rst-node!]
	][
		fc: as fn-call! malloc size? fn-call!
		SET_NODE_TYPE(fc RST_FN_CALL)
		call_accept: func [ACCEPT_FN_SPEC][
			v/visit-fn-call self data
		]
		fc/accept: :call_accept
		fc/token: pc
		fc/fn: fn
		ft: as fn-type! fn/type

		beg/next: null
		cur: :beg
		n: ft/n-params
		loop n [
			pc: advance-next pc end
			pc: parse-expr pc end :pp ctx
			cur/next: as rst-node! pp/value
			cur: cur/next
		]
		fc/args: as rst-expr! beg/next
		out/value: as int-ptr! fc
		pc
	]

	parse-block: func [
		blk		[red-block!]
		ctx		[context!]
		return: [rst-stmt!]
		/local
			pc	[cell!]
			end [cell!]
			stmt [rst-stmt! value]
			last-stmt [rst-stmt!]
			saved-blk [red-block!]
	][
		enter-block(blk)

		stmt/next: null
		last-stmt: ctx/last-stmt
		ctx/last-stmt: :stmt

		pc: block/rs-head blk
		end: block/rs-tail blk
		while [pc < end][
			pc: parse-statement pc end ctx
			pc: pc + 1
		]

		exit-block
		ctx/last-stmt: last-stmt
		stmt/next
	]

	_parse-if: func [
		pc		[cell!]
		end		[cell!]
		expr	[ptr-ptr!]
		ctx		[context!]
		either? [logic!]
		return: [cell!]
		/local
			cond	[ptr-value!]
			if-expr [if!]
	][
		if_accept: func [ACCEPT_FN_SPEC][
			v/visit-if self data
		]

		if-expr: xmalloc(if!)
		SET_NODE_TYPE(if-expr RST_IF)
		if-expr/token: pc
		if-expr/accept: :if_accept

		pc: parse-expr pc end :cond ctx
		if-expr/cond: as rst-expr! cond/value

		pc: expect-next pc end TYPE_BLOCK
		if-expr/true-blk: as red-block! pc
		if-expr/t-branch: parse-block as red-block! pc ctx

		if either? [
			pc: expect-next pc end TYPE_BLOCK
			if-expr/false-blk: as red-block! pc
			if-expr/f-branch: parse-block as red-block! pc ctx
		]	
		expr/value: as int-ptr! if-expr
		pc
	]

	parse-if: func [
		;pc end expr ctx
		KEYWORD_FN_SPEC
		/local
			w [red-word!]
	][
		w: as red-word! pc
		pc: advance-next pc end		;-- skip keyword: if/either
		_parse-if pc end expr ctx k_either = symbol/resolve w/symbol
	]

	parse-while: func [
		;pc end expr ctx
		KEYWORD_FN_SPEC
		/local
			w		[while!]
	][
		while_accept: func [ACCEPT_FN_SPEC][
			v/visit-while self data
		]
		w: as while! malloc size? while!
		SET_NODE_TYPE(w RST_WHILE)
		w/token: pc
		w/accept: :while_accept

		pc: expect-next pc end TYPE_BLOCK
		w/cond-blk: as red-block! pc
		w/cond: parse-block as red-block! pc ctx

		pc: expect-next pc end TYPE_BLOCK
		w/body-blk: as red-block! pc
		w/body: parse-block as red-block! pc ctx
		expr/value: as int-ptr! w
		pc
	]

	parse-continue: func [
		;pc end expr ctx
		KEYWORD_FN_SPEC
		/local
			c	[continue!]
	][
		cont_accept: func [ACCEPT_FN_SPEC][
			v/visit-continue self data
		]
		c: as continue! malloc size? continue!
		SET_NODE_TYPE(c RST_CONTINUE)
		c/token: pc
		c/accept: :cont_accept

		expr/value: as int-ptr! c
		pc
	]

	parse-break: func [
		;pc end expr ctx
		KEYWORD_FN_SPEC
		/local
			b	[break!]
	][
		break_accept: func [ACCEPT_FN_SPEC][
			v/visit-break self data
		]
		b: as break! malloc size? break!
		SET_NODE_TYPE(b RST_CONTINUE)
		b/token: pc
		b/accept: :break_accept

		expr/value: as int-ptr! b
		pc
	]

	make-return: func [
		pc		[cell!]
		expr	[rst-expr!]
		return: [return!]
		/local
			r	[return!]
	][
		return_accept: func [ACCEPT_FN_SPEC][
			v/visit-return self data
		]
		r: as return! malloc size? return!
		SET_NODE_TYPE(r RST_RETURN)
		r/token: pc
		r/accept: :return_accept
		r/expr: expr
		r
	]

	parse-return: func [
		;pc end expr ctx
		KEYWORD_FN_SPEC
		/local
			pos [cell!]
			r	[return!]
			val [ptr-value!]
	][
		pos: pc
		pc: advance-next pc end		;-- skip keyword: return
		pc: parse-expr pc end :val ctx
		r: make-return pos as rst-expr! val/value

		expr/value: as int-ptr! r
		pc
	]

	parse-exit: func [
		KEYWORD_FN_SPEC
		/local
			e	[exit!]
	][
		exit_accept: func [ACCEPT_FN_SPEC][
			v/visit-exit self data
		]
		e: xmalloc(exit!)
		SET_NODE_TYPE(e RST_EXIT)
		e/token: pc
		e/accept: :exit_accept

		expr/value: as int-ptr! e
		pc
	]

	parse-any: func [
		KEYWORD_FN_SPEC
	][]

	parse-all: func [
		KEYWORD_FN_SPEC
	][]

	fetch-type: func [
		pc		[cell!]
		end		[cell!]
		typeref [ptr-ptr!]
		return: [cell!]
		/local
			w	[red-word!]
			sym [integer!]
			blk [red-block!]
	][
		if T_BLOCK?(pc) [
			typeref/value: as int-ptr! pc
			return pc
		]

		blk: xmalloc(red-block!)
		w: as red-word! pc
		if TYPE_OF(w) <> TYPE_WORD [
			throw-error [pc "invalid AS expr, expect a word!"]
		]
		sym: symbol/resolve w/symbol

		typeref/value: as int-ptr! either any [
			sym = k_pointer!
			sym = k_struct!
			sym = k_function!
		][
			red/block/make-at blk 2
			red/block/rs-append blk pc
			pc: expect-next pc end TYPE_BLOCK
			red/block/rs-append blk pc
			blk
		][
			pc
		]
		pc
	]

	parse-as: func [
		KEYWORD_FN_SPEC
		/local
			c	[cast!]
			w	[red-word!]
			e	[ptr-value!]
	][
		cast_accept: func [ACCEPT_FN_SPEC][
			v/visit-cast self data
		]
		c: xmalloc(cast!)
		SET_NODE_TYPE(c RST_CAST)
		c/token: pc
		c/accept: :cast_accept

		pc: advance-next pc end
		pc: fetch-type pc end :e
		c/typeref: as cell! e/value
		pc: advance-next pc end
		w: as red-word! pc
		if all [T_WORD?(w) k_keep = symbol/resolve w/symbol][
			ADD_NODE_FLAGS(c RST_AS_KEEP)
			pc: advance-next pc end
		]
		pc: parse-expr pc end :e ctx
		c/expr: as rst-expr! e/value
		expr/value: as int-ptr! c
		pc
	]

	parse-declare: func [
		KEYWORD_FN_SPEC
		/local
			d	[declare!]
			e	[ptr-value!]
	][
		declare_accept: func [ACCEPT_FN_SPEC][
			v/visit-declare self data
		]
		d: xmalloc(declare!)
		SET_NODE_TYPE(d RST_DECLARE)
		d/token: pc
		d/accept: :declare_accept

		pc: advance-next pc end
		pc: fetch-type pc end :e
		d/typeref: as cell! e/value
		expr/value: as int-ptr! d
		pc
	]

	parse-unary: func [
		pc		[cell!]
		end		[cell!]
		expr	[ptr-ptr!]
		ctx		[context!]
		return: [cell!]
		/local
			e	[unary!]
			pv	[ptr-value!]
	][
		e: xmalloc(unary!)
		e/token: pc
		pc: advance-next pc end
		pc: parse-expr pc end :pv ctx
		e/expr: as rst-expr! pv/value
		expr/value: as int-ptr! e
		pc
	]

	parse-alias: func [
		pc		[cell!]
		end		[cell!]
		ctx		[context!]
		return: [cell!]
		/local
			name	[red-word!]
			sym		[integer!]
			val		[ptr-ptr!]
			e		[ptr-value!]
			t		[unresolved-type!]
	][
		name: as red-word! pc
		sym: symbol/resolve name/symbol
		val: hashmap/get ctx/typecache sym
		if val <> null [
			throw-error [pc "redefine type"]
		]

		pc: advance-next pc + 1 end
		pc: fetch-type pc end :e

		t: xmalloc(unresolved-type!)
		SET_TYPE_KIND(t RST_TYPE_UNRESOLVED)
		t/typeref: as cell! e/value
		hashmap/put ctx/typecache sym as int-ptr! t
		pc
	]

	parse-size?: func [
		KEYWORD_FN_SPEC
		/local
			e	 [unary!]
			err? [logic!]
	][
		sizeof_accept: func [ACCEPT_FN_SPEC][
			v/visit-size? self data
		]
		err?: ctx/throw-error?
		ctx/throw-error?: no
		pc: parse-unary pc end expr ctx
		ctx/throw-error?: err?

		e: as unary! expr/value
		if null? e/expr [	;-- not an expression, may be a type
			e/expr: as rst-expr! pc
			ADD_NODE_FLAGS(e RST_SIZE_TYPE)
		]
		e/accept: :sizeof_accept
		SET_NODE_TYPE(e RST_SIZEOF)
		pc
	]

	parse-not: func [
		KEYWORD_FN_SPEC
		/local
			e	[unary!]
			pv	[ptr-value!]
	][
		not_accept: func [ACCEPT_FN_SPEC][
			v/visit-not self data
		]
		pc: parse-unary pc end expr ctx

		e: as unary! expr/value
		e/accept: :not_accept
		SET_NODE_TYPE(e RST_NOT)
		pc
	]

	parse-null: func [
		KEYWORD_FN_SPEC
		/local
			e	[rst-expr!]
	][
		null_accept: func [ACCEPT_FN_SPEC][
			v/visit-literal self data
		]
		e: xmalloc(rst-expr!)
		SET_NODE_TYPE(e RST_NULL)
		e/token: pc
		e/accept: :null_accept
		e/type: type-system/null-type

		expr/value: as int-ptr! e
		pc
	]

	parse-until: func [
		KEYWORD_FN_SPEC
		/local
			w		[while!]
	][
		until_accept: func [ACCEPT_FN_SPEC][
			v/visit-until self data
		]
		w: as while! malloc size? while!
		SET_NODE_TYPE(w RST_UNTIL)
		w/token: pc
		w/accept: :until_accept

		pc: expect-next pc end TYPE_BLOCK
		w/body-blk: as red-block! pc
		w/body: parse-block as red-block! pc ctx
		expr/value: as int-ptr! w
		pc
	]

	parse-loop: func [
		KEYWORD_FN_SPEC
			/local
			w		[while!]
			pv		[ptr-value!]
	][
		loop_accept: func [ACCEPT_FN_SPEC][
			v/visit-loop self data
		]
		w: as while! malloc size? while!
		SET_NODE_TYPE(w RST_LOOP)
		w/token: pc
		w/accept: :loop_accept

		pc: advance-next pc end
		w/cond-blk: as red-block! pc
		pc: parse-expr pc end :pv ctx
		w/cond: as rst-stmt! pv/value

		pc: expect-next pc end TYPE_BLOCK
		w/body-blk: as red-block! pc
		w/body: parse-block as red-block! pc ctx
		expr/value: as int-ptr! w
		pc
	]

	parse-case: func [
		KEYWORD_FN_SPEC
		/local
			c		[case!]
			blk		[red-block!]
			p		[cell!]
			s-tail	[cell!]
			e		[ptr-value!]
			if-expr	[if!]
			last-if [if!]
			first-if [if!]
			saved-blk [red-block!]
	][
		case_accept: func [ACCEPT_FN_SPEC][
			v/visit-case self data
		]

		blk: as red-block! expect-next pc end TYPE_BLOCK
		p: block/rs-head blk
		s-tail: block/rs-tail blk
		if p = s-tail [throw-error [pc "empty case block"]]

		c: xmalloc(case!)
		SET_NODE_TYPE(c RST_CASE)
		c/token: pc
		c/accept: :case_accept

		enter-block(blk)
		last-if: null
		first-if: null
		while [p < s-tail][
			p: _parse-if p s-tail :e ctx no
			if-expr: as if! e/value
			if null? first-if [first-if: if-expr]
			if last-if <> null [last-if/f-branch: as rst-stmt! if-expr]
			last-if: if-expr
			p: p + 1
		]
		exit-block

		c/cases: first-if
		expr/value: as int-ptr! c
		as cell! blk
	]

	parse-switch: func [
		KEYWORD_FN_SPEC
		/local
			s		[switch!]
			c		[switch-case!]
			cur		[switch-case!]
			cases	[switch-case! value]
			e		[rst-expr!]
			ty		[integer!]
			pv		[ptr-value!]
			blk		[red-block!]
			p		[cell!]
			s-tail	[cell!]
			w		[red-word!]
			saved-blk [red-block!]
	][
		switch_accept: func [ACCEPT_FN_SPEC][
			v/visit-switch self data
		]
	
		s: xmalloc(switch!)
		SET_NODE_TYPE(s RST_SWITCH)
		s/token: pc
		s/accept: :switch_accept

		pc: advance-next pc end		;-- skip keyword switch
		pc: parse-expr pc end :pv ctx
		s/expr: as rst-expr! pv/value

		blk: as red-block! expect-next pc end TYPE_BLOCK
		p: block/rs-head blk
		s-tail: block/rs-tail blk
		if p = s-tail [throw-error [blk "empty switch block"]]

		enter-block(blk)
		cur: :cases
		cur/next: null
		while [p < s-tail][
			w: as red-word! p
			if all [T_WORD?(w) k_default = symbol/resolve w/symbol][
				p: expect-next p s-tail TYPE_BLOCK
				s/defcase: parse-block as red-block! p ctx
				if p + 1 <> s-tail [throw-error [p "wrong syntax in SWITCH block"]]
			]

			c: xmalloc(switch-case!)
			p: parse-expr p s-tail :pv ctx
			e: as rst-expr! pv/value
			ty: NODE_TYPE(e)
			if all [ty <> RST_INT ty <> RST_BYTE][
				throw-error [p "expect integer! or byte! literal value"]
			]

			p: expect-next p s-tail TYPE_BLOCK
			c/body: parse-block as red-block! p ctx
			c/expr: e
			
			cur/next: c
			cur: c
			p: p + 1
		]
		exit-block

		s/cases: cases/next
		expr/value: as int-ptr! s
		as cell! blk
	]

	parse-throw: func [
		KEYWORD_FN_SPEC
	][]

	parse-catch: func [
		KEYWORD_FN_SPEC
	][]

	parse-assert: func [
		KEYWORD_FN_SPEC
	][]

	parse-comment: func [
		KEYWORD_FN_SPEC
		/local
			e	[rst-stmt!]
	][
		comment_accept: func [ACCEPT_FN_SPEC][
			v/visit-comment self data
		]
		e: xmalloc(rst-stmt!)
		SET_NODE_TYPE(e RST_COMMENT)
		e/token: pc
		e/accept: :comment_accept

		expr/value: as int-ptr! e
		pc + 1
	]

	parse-with: func [
		KEYWORD_FN_SPEC
		/local
			blk		 [red-block!]
			with-ns	 [vector!]
			ns-size	 [integer!]
			c		 [context!]
			val		 [cell!]
			s-tail	 [cell!]
			saved-blk [red-block!]
	][
		blk: as red-block! advance-next pc end
		with-ns: ctx/with-ns
		if null? with-ns [
			with-ns: ptr-vector/make 4
			ctx/with-ns: with-ns
		]

		ns-size: with-ns/length

		either T_WORD?(blk) [
			c: find-context as red-word! blk ctx
			vector/append-ptr with-ns as byte-ptr! c
		][
			if TYPE_OF(blk) <> TYPE_BLOCK [throw-error [blk "expected word! or block!"]]
			val: block/rs-head blk
			s-tail: block/rs-tail blk
			enter-block(blk)
			while [val < s-tail][
				c: find-context as red-word! val ctx
				vector/append-ptr with-ns as byte-ptr! c
				val: val + 1
			]
			exit-block
		]

		pc: expect-next pc + 1 end TYPE_BLOCK
		blk: as red-block! pc
		enter-block(blk)
		val: block/rs-head blk
		s-tail: block/rs-tail blk
		while [val < s-tail][
			val: parse-statement val s-tail ctx
			val: val + 1
		]
		exit-block

		either zero? ns-size [
			vector/destroy with-ns
			ctx/with-ns: null
		][
			with-ns/length: ns-size		;-- pop back
		]
		pc
	]

	parse-use: func [
		KEYWORD_FN_SPEC
	][]

	parse-logic: func [
		;pc end expr ctx
		KEYWORD_FN_SPEC
		/local
			b	[logic-literal!]
			bl	[red-logic!]
	][
		bl: as red-logic! pc
		b: as logic-literal! malloc size? logic-literal!
		b_accept: func [ACCEPT_FN_SPEC][
			v/visit-literal self data
		]
		SET_NODE_TYPE(b RST_LOGIC)
		b/token: pc
		b/value: bl/value
		b/accept: :b_accept
		b/type: type-system/logic-type

		expr/value: as int-ptr! b
		pc
	]

	parse-sub-expr: func [
		pc		[cell!]
		end		[cell!]
		expr	[ptr-ptr!]	;-- a pointer to receive the expr
		ctx		[context!]
		return: [cell!]
		/local
			sym [integer!]
			w	[red-word!]
			p	[ptr-ptr!]
			v	[rst-node!]
			parse-keyword [keyword-fn!]
	][
		switch TYPE_OF(pc) [
			TYPE_WORD [
				w: as red-word! pc
				v: find-word w ctx -1
				either v <> null [
					switch NODE_TYPE(v) [
						RST_FUNC		[pc: parse-call pc end as fn! v expr ctx]
						RST_VAR_DECL	[expr/value: as int-ptr! make-variable as var-decl! v pc]
						default			[unreachable pc]
					]
				][
					sym: symbol/resolve w/symbol
					p: hashmap/get keywords sym
					either p <> null [		;-- keyword
						parse-keyword: as keyword-fn! p/value
						pc: parse-keyword pc end expr ctx
					][
						either ctx/throw-error? [
							throw-error [pc "undefined symbol:" w]
						][
							expr/value: null
							return pc
						]
					]
				]
			]
			TYPE_INTEGER [
				expr/value: as int-ptr! make-int pc
			]
			TYPE_FLOAT [
				expr/value: as int-ptr! make-float pc
			]
			TYPE_STRING [
				expr/value: as int-ptr! make-lit-array pc
			]
			TYPE_GET_WORD [
				
			]
			TYPE_PATH [0]
			TYPE_GET_PATH [0]
			TYPE_ISSUE [
				w: as red-word! pc
				sym: symbol/resolve w/symbol
				case [
					sym = k_get [0]
					sym = k_in [0]
					sym = k_u16 [0]
					true [throw-error [pc "unknown directive:" w]]
				]
			]
			default [throw-error [pc "invalid expression"]]
		]
		pc
	]

	parse-infix-op: func [
		pc		[cell!]
		end		[cell!]
		expr	[ptr-ptr!]
		ctx		[context!]
		return: [cell!]
		/local
			w		[red-word!]
			infix?	[logic!]
			ptr		[ptr-ptr!]
			sym		[integer!]
			node	[rst-expr!]
			type	[rst-node-type!]
			t		[rst-type!]
			flag	[integer!]
			bin		[bin-op!]
			left	[rst-expr!]
			right	[ptr-value!]
			pos		[cell!]
			op		[int-ptr!]
			val		[ptr-ptr!]
			pc2		[cell!]
	][
		left: as rst-expr! expr/value
		while [
			pc2: pc + 1
			all [pc2 < end T_WORD?(pc2)]
		][
			flag: 0
			infix?: no
			w: as red-word! pc2
			sym: symbol/resolve w/symbol
			val: hashmap/get infix-Ops sym
			either null <> val [
				infix?: yes
				flag: RST_INFIX_OP
				op: val/value
			][
				node: as rst-expr! find-word w ctx -1
				if node <> null [
					type: NODE_TYPE(node)
					if any [type = RST_VAR_DECL type = RST_FUNC][
						t: node/type
						if all [t <> null FN_ATTRS(t) and FN_INFIX <> 0][
							infix?: yes
							flag: RST_INFIX_FN
							op: as int-ptr! t
						]
					]
				]
			]
			either infix? [
				pos: pc2
				pc: parse-sub-expr advance-next pc2 end end :right ctx
				bin: make-bin-op op left as rst-expr! right/value pos
				ADD_NODE_FLAGS(bin flag)
				left: as rst-expr! bin
			][break]
		]
		expr/value: as int-ptr! left
		pc
	]

	parse-expr: func [
		pc		[cell!]
		end		[cell!]
		expr	[ptr-ptr!]	;-- a pointer to receive the expr
		ctx		[context!]
		return: [cell!]
	][
		pc: parse-sub-expr pc end expr ctx
		parse-infix-op pc end expr ctx
	]

	find-with-ns: func [
		name	[red-word!]
		ctx		[context!]
		type	[integer!]
		return: [rst-node!]
		/local
			v	[vector!]
			n	[integer!]
			p	[ptr-ptr!]
			c	[context!]
			d	[rst-node!]
	][
		v: ctx/with-ns
		n: VECTOR_SIZE?(v)
		if zero? n [return null]

		p: VECTOR_DATA(v)
		p: p + n		;-- reverse order
		loop n [
			p: p - 1
			c: as context! p/value
			d: find-word name c type
			if d <> null [return d]
		]
		null
	]

	find-word: func [
		name	[red-word!]
		ctx		[context!]
		type	[integer!]		;-- if < 0: match any type
		return: [rst-node!]
		/local
			sym [integer!]
			val [ptr-ptr!]
			d	[rst-node!]
	][
		sym: symbol/resolve name/symbol
		while [ctx <> null][
			until [
				if ctx/with-ns <> null [
					d: find-with-ns name ctx type
					if d <> null [return d]
				]

				val: hashmap/get ctx/decls sym
				ctx: ctx/parent
				any [null? ctx val <> null]
			]
			if val <> null [
				d: as rst-node! val/value
				if any [type < 0 NODE_TYPE(d) = type][return d]
			]
		]
		null
	]

	find-context: func [
		name	[red-word!]
		ctx		[context!]
		return: [context!]
		/local
			c	[context!]
	][
		c: as context! find-word name ctx RST_CONTEXT
		if null? c [throw-error [name "undeclared context"]]
		c
	]

	literal-expr?: func [
		e		[rst-expr!]
		return: [logic!]
		/local
			t	[integer!]
			c	[cast!]
	][
		t: NODE_TYPE(e)
		c: as cast! e
		any [
			t <= RST_DECLARE
			all [
				t = RST_CAST
				literal-expr? c/expr
			]
		]
	]

	parse-assignment: func [
		pc		[cell!]
		end		[cell!]
		out		[ptr-ptr!]
		ctx		[context!]
		return: [cell!]
		/local
			var		[var-decl!]
			flags	[integer!]
			pos		[cell!]
			s		[rst-stmt!]
	][
		var: null
		switch TYPE_OF(pc) [
			TYPE_SET_WORD [
				var: as var-decl! find-word as red-word! pc ctx RST_VAR_DECL
				pos: pc
				flags: NODE_FLAGS(ctx)
				either flags and RST_FN_CTX <> 0 [
					if null? var [
						throw-error [pc "undefined symbol:" pc]
					]
				][
					if null? var [
						var: make-var-decl pc null
						add-decl ctx pc as int-ptr! var
						pc: parse-assignment advance-next pc end end out ctx
						var/init: as rst-expr! out/value
						unless literal-expr? as rst-expr! out/value [
							s: as rst-stmt! make-assignment var as rst-expr! out/value pos
							ctx/last-stmt/next: s
							ctx/last-stmt: s
						]
						return pc
					]
				]
			]
			TYPE_SET_PATH [0]
			default [
				return parse-expr pc end out ctx
			]
		]

		pc: parse-assignment advance-next pc end end out ctx
		s: as rst-stmt! make-assignment var as rst-expr! out/value pos
		ctx/last-stmt/next: s
		ctx/last-stmt: s
		pc
	]

	parse-statement: func [
		pc		[cell!]
		end		[cell!]
		ctx		[context!]
		return: [cell!]
		/local
			w	[red-word!]
			sym [integer!]
			ptr [ptr-value!]
			s	[rst-stmt!]
			add? [logic!]
	][
		add?: yes
		ptr/value: null
		switch TYPE_OF(pc) [
			TYPE_WORD [pc: parse-expr pc end :ptr ctx]
			TYPE_ISSUE [
				w: as red-word! pc
				sym: symbol/resolve w/symbol
				case [
					sym = k_call [0]
					sym = k_typecheck [0]
					sym = k_inline [0]
					sym = k_verbose [0]
					sym = k_user-code [0]
					sym = k_build-date [0]
					true [pc: parse-expr pc end :ptr ctx]
				]
			]
			default [
				pc: parse-assignment pc end :ptr ctx
				add?: no
			]
		]
		if add? [
			assert ptr/value <> null
			s: as rst-stmt! ptr/value
			ctx/last-stmt/next: s
			ctx/last-stmt: s
		]
		pc
	]

	parse-import: func [
		blk		[red-block!]
		attr	[integer!]
		lib		[cell!]
		ctx		[context!]
		/local
			p			[cell!]
			end			[cell!]
			name		[cell!]
			import-name	[cell!]
			ft			[fn-type!]
			fn			[import-fn!]
			saved-blk	[red-block!]
	][
		p: block/rs-head blk
		end: block/rs-tail blk
		if p = end [exit]

		enter-block(blk)

		while [p < end][
			name: expect p TYPE_SET_WORD
			import-name: expect-next p end TYPE_STRING
			p: expect-next import-name end TYPE_BLOCK

			fn: as import-fn! make-func name ctx yes
			fn/import-lib: lib
			fn/import-name: import-name
			ft: parse-fn-spec as red-block! p as fn! fn
			fn/type: as rst-type! ft 
			ADD_NODE_FLAGS(fn RST_IMPORT_FN)
			ADD_FN_ATTRS(ft attr)

			unless add-decl ctx name as int-ptr! fn [
				throw-error [name "symbol name was already defined"]
			]
			p: p + 1
		]

		exit-block
	]

	parse-imports: func [
		pc		[cell!]
		end		[cell!]
		ctx		[context!]
		return: [cell!]
		/local
			blk [red-block!]
			p	[cell!]
			sym [integer!]
			w	[red-word!]
			fn	[import-fn!]
			lib [cell!]
			attr [integer!]
			saved-blk [red-block!]
	][
		pc: expect-next pc end TYPE_BLOCK
		blk: as red-block! pc
		p: block/rs-head blk
		end: block/rs-tail blk
		if p = end [return pc]

		enter-block(blk)

		while [p < end][
			lib: expect p TYPE_STRING
			p: expect-next p end TYPE_WORD

			;-- calling convention
			w: as red-word! p
			attr: 0
			sym: symbol/resolve w/symbol
			attr: attr or case [
				sym = k_cdecl	 [FN_CC_CDECL]
				sym = k_stdcall	 [FN_CC_STDCALL]
				true [
					throw-error [p "unknown calling convention:" p]
					0
				]
			]

			p: expect-next p end TYPE_BLOCK
			parse-import as red-block! p attr lib ctx
			p: p + 1
		]

		exit-block
		pc
	]

	parse-directive: func [
		pc		[cell!]
		end		[cell!]
		ctx		[context!]
		return: [cell!]
		/local
			w	[red-word!]
			sym [integer!]
	][
		w: as red-word! pc
		sym: symbol/resolve w/symbol
		case [
			sym = k_import [
				pc: parse-imports pc end ctx
			]
			sym = k_export [0]
			sym = k_syscall [0]
			sym = k_script [0]
			true [pc: parse-statement pc end ctx]
		]
		pc
	]

	add-decl: func [
		ctx		[context!]
		name	[cell!]
		decl	[int-ptr!]
		return: [logic!]		;-- false if already exist
		/local
			w	[red-word!]
			sym	[integer!]
	][
		w: as red-word! name
		sym: symbol/resolve w/symbol
		either null? hashmap/get ctx/decls sym [
			hashmap/put ctx/decls sym decl
			true
		][false]
	]

	parse-context: func [
		name	[cell!]
		src		[red-block!]
		parent	[context!]
		f-ctx	[context!]
		return: [context!]
		/local
			pc	[cell!]
			pc2 [cell!]
			end [cell!]
			sym [integer!]
			w	[red-word!]
			ctx [context!]
			c2	[context!]
			ptr [ptr-value!]
			saved-blk [red-block!]
	][
		cur-blk: src
		ctx: either null? f-ctx [make-ctx name parent no][f-ctx]
		pc: block/rs-head src
		end: block/rs-tail src
		while [pc < end][
			switch TYPE_OF(pc) [
				TYPE_SET_WORD [
					pc2: advance-next pc end
					pc: either T_WORD?(pc2) [
						w: as red-word! pc2
						sym: symbol/resolve w/symbol
						case [
							any [sym = k_func sym = k_function][
								fetch-func pc end ctx
							]
							sym = k_alias [
								parse-alias pc end ctx
							]
							sym = k_context [
								if f-ctx <> null [throw-error [pc "context has to be declared at root level"]]

								pc2: expect-next pc2 end TYPE_BLOCK
								saved-blk: cur-blk
								c2: parse-context pc as red-block! pc2 ctx f-ctx
								cur-blk: saved-blk
								unless add-decl ctx pc as int-ptr! c2 [
									throw-error [pc "context name is already taken:" pc]
								]
								pc2
							]
							true [parse-assignment pc end :ptr ctx]
						]
					][
						parse-assignment pc end :ptr ctx
					]
				]
				TYPE_ISSUE [pc: parse-directive pc end ctx]
				default [pc: parse-statement pc end ctx]
			]
			pc: pc + 1
		]
		ctx
	]

	get-attributes: func [
		blk		[red-block!]
		return: [integer!]
		/local
			p	[red-word!]
			end [red-word!]
			attr [integer!]
			sym [integer!]
			saved-blk [red-block!]
	][
		enter-block(blk)
		attr: 0
		p: as red-word! block/rs-head blk
		end: as red-word! block/rs-tail blk
		while [p < end][
			either T_WORD?(p) [
				sym: symbol/resolve p/symbol
				attr: attr or case [
					sym = k_cdecl	 [FN_CC_CDECL]
					sym = k_stdcall	 [FN_CC_STDCALL]
					sym = k_variadic [FN_VARIADIC]
					sym = k_typed	 [FN_TYPED]
					sym = k_infix	 [FN_INFIX]
					sym = k_custom	 [FN_CUSTOM]
					true [
						throw-error [p "unknown func attribute:" p]
						0
					]
				]
			][
				throw-error [p "invalid func attribute:" p]
			]
			p: p + 1
		]
		exit-block
		attr
	]

	parse-local: func [
		p		[cell!]
		end		[cell!]
		fn		[fn!]
		return: [cell!]
		/local
			t	[cell!]
			n	[integer!]
			ty	[integer!]
			cur	[var-decl!]
			list [var-decl! value]
	][
		list/next: null
		cur: :list
		n: 0
		while [p < end][
			ty: TYPE_OF(p)
			case [
				any [ty = TYPE_WORD ty = TYPE_STRING][n: n + 1]
				ty = TYPE_BLOCK [
					if zero? n [throw-error [p "missing locals"]]
					t: p - 1
					until [
						if T_WORD?(t) [
							cur/next: make-var-decl t as red-block! p
							cur: cur/next
							ADD_NODE_FLAGS(cur RST_VAR_LOCAL)
						]
						t: t - 1
						n: n - 1
						zero? n
					]
				]
				true [throw-error [p "invalid locals:" p]]
			]
			p: p + 1
		]
		if fn <> null [
			fn/locals: list/next
		]
		p
	]

	parse-fn-spec: func [
		spec	[red-block!]
		fn		[fn!]
		return: [fn-type!]
		/local
			ft	[fn-type!]
			p	[cell!]
			end [cell!]
			p2	[cell!]
			w	[red-word!]
			t s [integer!]
			cur [var-decl!]
			list [var-decl! value]
			attr [integer!]
			flag [integer!]
			ty	 [integer!]
			saved-blk [red-block!]
	][
		ft: as fn-type! malloc size? fn-type!
		SET_TYPE_KIND(ft RST_TYPE_FUNC)
		ft/spec: spec

		p: block/rs-head spec
		end: block/rs-tail spec

		p: skip p end TYPE_STRING			;-- skip doc strings

		if p = end [return ft]

		if T_BLOCK?(p) [					;-- attributes
			attr: get-attributes as red-block! p
			ADD_FN_ATTRS(ft attr)
			p: skip p + 1 end TYPE_STRING	;-- skip doc strings
		]

		enter-block(spec)

		list/next: null
		cur: :list
		s: 0	;-- initial state
		w: as red-word! p
		while [w < as red-word! end][		;-- parse params, return: and /local
			ty: TYPE_OF(w)
			case [
				;; param = word "[" type "]" doc-string?
				all [s = 0 ty = TYPE_WORD][
					p2: expect-next p end TYPE_BLOCK
					cur/next: make-var-decl p as red-block! p2
					cur: cur/next
					flag: RST_VAR_PARAM or RST_VAR_LOCAL
					ADD_NODE_FLAGS(cur flag)
					cur/init: as rst-expr! ft/n-params ;-- parameter index
					p: p2 + 1
					ft/n-params: ft/n-params + 1
				]
				;; return-spec = return: "[" type "]" doc-string?
				all [s < 1 ty = TYPE_SET_WORD k_return = symbol/resolve w/symbol][
					s: 1
					p: expect-next as cell! w end TYPE_BLOCK
					ft/ret-typeref: as red-block! p
					p: p + 1
				]
				;; local-var = word+ ("[" type "]")? doc-string?
				all [s < 2 ty = TYPE_REFINEMENT k_local = symbol/resolve w/symbol fn <> null][
					s: 2
					p: parse-local as cell! w + 1 end fn
				]
				true [throw-error [w "invalid func spec" w]]
			]
			w: as red-word! skip p end TYPE_STRING
		]
		exit-block

		ft/params: list/next
		ft
	]

	fetch-func: func [
		pc		[cell!]
		end		[cell!]
		ctx		[context!]
		return: [cell!]
		/local
			fn	[fn!]
			spec [red-block!]
			body [red-block!]
	][
		fn: make-func pc ctx no
		body: as red-block! advance pc end 3
		spec: body - 1
		fn/body: body
		fn/type: as rst-type! parse-fn-spec spec fn

		unless add-decl ctx pc as int-ptr! fn [
			throw-error [pc "symbol name was already defined"]
		]
		as cell! body
	]
]