"""
    Go back and forth between subscript and index
"""
module SubscriptIndexer

export unitspace
export states
export getconv

abstract Space

type UnitSpace <: Space
  states::Vector{Any}
end

type ProductSpace <: Space
  subspaces ::Vector{UnitSpace}
end

function unitspace(states...)
  stateunique = unique(states)
  @assert(length(stateunique) == length(states))
  return UnitSpace(collect(states))
end

import Base: *

function *(s1 ::UnitSpace, s2 ::UnitSpace)
  return ProductSpace([s1; s2])
end

function *(s1 ::ProductSpace, s2 ::UnitSpace)
  @show [s1.subspaces; s2]
  return ProductSpace([s1.subspaces; s2])
end

function *(s1 ::UnitSpace, s2 ::ProductSpace)
  return ProductSpace([s1; s2.subspaces])
end

function *(s1 ::ProductSpace, s2 ::ProductSpace)
  return ProductSpace([s1.subspaces; s2.subspaces])
end



module ZeroBased

using ..UnitSpace
using ..ProductSpace

function getconv(space ::UnitSpace)
  states = copy(space.states)
  stateindices = Dict{Any, Integer}(state => idx-1 for (idx, state) in enumerate(states))

  n = length(states)
  sub2idx = (sub) -> stateindices[sub]
  idx2sub = (idx ::Integer) -> states[idx+1]
  return (n, sub2idx, idx2sub)
end


function getconv(space ::ProductSpace)
  convs = map((subspace) -> getconv(subspace), space.subspaces)
  sizes = [i for (i, sub2idx, idx2sub) in convs]
  rawstrides = cumprod([1; sizes])
  strides = rawstrides[1:end-1]

  sub2idxs = [sub2idx for (i, sub2idx, idx2sub) in convs]
  idx2subs = [idx2sub for (i, sub2idx, idx2sub) in convs]
 
  sub2idx = (subs...) -> begin
    idxs = map((sub2idx, sub) -> sub2idx(sub), sub2idxs, subs)
    idxs = collect(idxs)
    return dot(strides, idxs)
  end

  idx2sub = (idx) -> begin
    idxs = map((stride, size) -> mod(fld(idx, stride), size), strides, sizes)
    subs = map((idx2sub, idx) -> idx2sub(idx), idx2subs, idxs)
    return subs
  end

  return (rawstrides[end], sub2idx, idx2sub)
end

end


function getconv(space ::UnitSpace)
  states = copy(space.states)
  stateindices = Dict{Any, Integer}(state => idx for (idx, state) in enumerate(states))
  n = length(states)
  sub2idx = (sub) -> stateindices[sub]
  idx2sub = (idx ::Integer) -> states[idx]
  return (n, sub2idx, idx2sub)
end


function getconv(space ::ProductSpace)
  (n, sub2idx0, idx2sub0) = ZeroBased.getconv(space)
  sub2idx = (subs...) -> (sub2idx0(subs...) + 1)
  idx2sub = (idx) -> idx2sub0(idx-1)
  return (n, sub2idx, idx2sub)
end


import Base: in
in(item, unitspace::UnitSpace) = in(item, unitspace.states)
function in(item, productspace ::ProductSpace)
  all((item, space) -> in(item, space), item, productspace.subspaces)
end

states(unitspace ::UnitSpace) = unitspace.states
function states(productspace ::ProductSpace)
  # TODO: USE ITERATOR TOOLS IN v0.6
  (n, sub2idx, idx2sub) = getconv(productspace)
  return [idx2sub(idx) for idx in 1:n]
end

end