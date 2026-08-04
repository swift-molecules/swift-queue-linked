// Deliberate build-breaking fixture for swift-institute/.github#276 predicate 13
// demonstration (negative/BLOCK control for `verification / workspace`).
// This file is never intended to merge — it exists only to prove the trusted
// private verifier reports `failure`, not `success`, for a head that cannot
// build. See swift-institute/.github#276.
let predicateThirteenBlockFixture: Int = this is not valid swift syntax at all
