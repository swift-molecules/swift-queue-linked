// exports.swift
// `Queue Linked Primitives` is the ops module AND the [MOD-005] umbrella for this
// package: it re-exports the `Queue Linked Primitive` type module plus the upstream
// namespace owner, so `import Queue_Linked_Primitives` surfaces the whole package.

@_exported public import Queue_Linked_Primitive
@_exported public import Queue_Primitives
