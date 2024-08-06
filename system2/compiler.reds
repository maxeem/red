Red/System [
	Title:   "Red/System compiler"
	File: 	 %compiler.reds
	Tabs:	 4
	Rights:  "Copyright (C) 2011-2018 Red Foundation. All rights reserved."
	License: "BSD-3 - https://github.com/red/red/blob/master/BSD-3-License.txt"
]

compiler: context [

	#define enter-block(blk) [
		saved-blk: cur-blk
		cur-blk: blk
	]

	#define exit-block [
		cur-blk: saved-blk
	]

	#define ARRAY_DATA(arr) (as ptr-ptr! (arr + 1))
	#define array-value! [array-1! value]
	#define INIT_ARRAY_VALUE(a v) [a/length: 1 a/value: as byte-ptr! v]

	ptr-array!: alias struct! [
		length	[integer!]
		;--data
	]

	array-1!: alias struct! [		;-- ptr array with one value
		length	[integer!]
		value	[byte-ptr!]
	]

	empty-array: as ptr-array! 0

	ptr-array: context [
		make: func [
			size	[integer!]
			return: [ptr-array!]
			/local
				a	[ptr-array!]
		][
			a: as ptr-array! malloc (size * size? int-ptr!) + size? ptr-array!
			a/length: size
			a
		]

		copy: func [
			arr		[ptr-array!]
			return: [ptr-array!]
			/local
				new [ptr-array!]
		][
			new: make arr/length
			copy-memory as byte-ptr! ARRAY_DATA(new) as byte-ptr! ARRAY_DATA(arr) arr/length * size? int-ptr!
			new
		]

		grow: func [
			arr		[ptr-array!]
			length	[integer!]
			return: [ptr-array!]
			/local
				a	[ptr-array!]
		][
			either length > arr/length [
				a: make length
				copy-memory as byte-ptr! ARRAY_DATA(a) as byte-ptr! ARRAY_DATA(arr) arr/length * size? int-ptr!
				a
			][
				arr
			]
		]

		append: func [
			arr		[ptr-array!]
			ptr		[byte-ptr!]
			return: [ptr-array!]
			/local
				a	[ptr-array!]
				len [integer!]
				p	[ptr-ptr!]
				pp	[ptr-ptr!]
		][
			len: arr/length
			a: make len + 1
			p: ARRAY_DATA(a)
			pp: ARRAY_DATA(arr)
			loop len [
				p/value: pp/value
				p: p + 1
				pp: pp + 1
			]
			p/value: as int-ptr! ptr
			a
		]
	]

	#include %utils/vector.reds
	#include %utils/mempool.reds
	#include %utils/hashmap.reds
	#include %opcode.reds
	#include %parser.reds
	#include %rst-printer.reds
	#include %op-cache.reds
	#include %type-checker.reds
	#include %ir-graph.reds

	_mempool: as mempool! 0

	src-blk: as red-block! 0
	cur-blk: as red-block! 0
	script: as cell! 0

	prin-token: func [v [cell!]][
		if null? v [exit]
		#call [prin-cell v]
	]

	;@@ the memory returned should be zeroed
	malloc: func [size [integer!] return: [byte-ptr!]][
		mempool/alloc _mempool size
	]

	calc-line: func [
		pc		[cell!]
		return: [integer!]
		/local
			idx		[integer!]
			beg		[cell!]
			header	[cell!]
			prev	[integer!]
			p		[red-pair!]
	][
		header: block/rs-abs-at cur-blk 0
		beg: block/rs-head cur-blk
		idx: (as-integer pc - beg) >> 4 + 1
		if cur-blk = src-blk [idx: idx + 2]		;-- skip header Red/System [...]
		prev: 1

		while [
			header: header + 1
			header < beg
		][
			p: as red-pair! header
			if p/y = idx [return p/x]
			if p/y > idx [return prev]
			prev: p/x
		]
		p/x
	]

	throw-error: func [
		[typed] count [integer!] list [typed-value!]
		/local
			s	[c-string!]
			w	[cell!]
			pc	[cell!]
			p	[cell!]
			h	[integer!]
	][
		pc: as cell! list/value
		list: list + 1
		count: count - 1
		
		prin "*** Compilation Error: "
		until [
			either list/type = type-c-string! [
				s: as-c-string list/value prin s
			][
				w: as cell! list/value
				if w <> null [prin-token w]
			]

			count: count - 1	
			if count <> 0 [prin " "]

			list: list + 1
			zero? count
		]
		print "^/*** in file: " prin-token compiler/script
		print ["^/*** at line: " calc-line pc lf]
		p: block/rs-head cur-blk
		h: cur-blk/head
		cur-blk/head: (as-integer pc - p) >> 4 + h
		print "*** near: " #call [prin-block cur-blk 200]
		cur-blk/head: h
		print "^/"
		quit 1
	]

	comp-context: func [
		name	[cell!]
		src		[red-block!]
		parent	[context!]
		f-ctx	[context!]
		return: [context!]
		/local
			ctx [context!]
	][
		src-blk: src
		ctx: parser/parse-context name src parent f-ctx
		type-checker/check ctx
		rst-printer/print-program ctx
		ctx
	]

	init-func-ctx: func [
		ctx			[context!]
		fn			[fn!]
		/local
			ft		[fn-type!]
			var		[var-decl!]
			add-decls [subroutine!]
	][
		add-decls: [
			while [var <> null][
				unless parser/add-decl ctx var/token as int-ptr! var [
					throw-error [var/token "symbol name was already defined"]
				]
				var: var/next
			]
		]

		ADD_NODE_FLAGS(ctx RST_FN_CTX)

		ft: as fn-type! fn/type
		var: ft/params
		add-decls

		var: fn/locals
		add-decls
	]

	comp-functions: func [
		ctx		[context!]
		/local
			n		[integer!]
			decls	[int-ptr!]
			kv		[int-ptr!]
			f-ctx	[context!]
			fn		[fn!]
	][
		if null? ctx [exit]

		decls: ctx/decls
		n: hashmap/size? decls

		kv: null
		loop n [
			kv: hashmap/next decls kv
			fn: as fn! kv/2
			if NODE_TYPE(fn) = RST_FUNC [
				cur-blk: fn/body
				f-ctx: parser/make-ctx fn/token ctx yes		;@@ reuse f-ctx?
				init-func-ctx f-ctx fn
				comp-context fn/token fn/body ctx f-ctx
			]
		]
		comp-functions ctx/child
		comp-functions ctx/next
	]

	comp-dialect: func [
		src			[red-block!]
		job			[red-object!]
		/local
			ctx 	[context!]
			n		[integer!]
			decls	[int-ptr!]
			kv		[int-ptr!]
			fn		[fn!]
	][
		script: object/rs-select job as cell! word/load "script"
		ctx: comp-context null src null null
		comp-functions ctx
	]

	init: does [
		_mempool: mempool/make
		empty-array: ptr-array/make 0

		parser/init
		op-cache/init
		type-system/init
	]

	clean: does [
		mempool/destroy _mempool
	]
]