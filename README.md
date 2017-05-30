# SubscriptIndexer.jl

Convert between subscript (of any type, of any length) and index (one-based).


## Example

```julia
using SubscriptIndexer

spinspace = unitspace(:up, :dn)
orbitalspace = unitspace("A", "B")
sitespace = spinspace * orbitalspace

(n, sub2idx, idx2sub) = getconv(sitespace)

@show n
for idx = 1:n
  @show idx, idx2sub(idx)
end

(n, sub2idx, idx2sub) = getconv(spinspace * sitespace)

@show n
for idx = 1:n
  @show idx, idx2sub(idx)
end
```