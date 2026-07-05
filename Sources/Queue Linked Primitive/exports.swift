// exports.swift
// Re-exports for Queue Linked Primitive (the linked-queue type module).
// Re-exports the Queue namespace shell plus the arena buffer-linked backing the linked-queue
// type surface composes, so `import Queue_Linked_Primitive` surfaces the whole type face.

@_exported public import Buffer_Linked_Primitive
@_exported public import Index_Primitives
@_exported public import Queue_Primitives
