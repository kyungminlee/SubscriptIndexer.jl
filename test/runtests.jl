using Base.Test

using SubscriptIndexer

@testset "Test" begin

  s1 = unitspace("A", "B")
  s2 = unitspace(:x, :y, '3')
  s3 = s1 * s2

  @testset "strings" begin
    (n, sub2idx, idx2sub) = getconv(s1)
    @test n == 2
    @test 1 == sub2idx("A")
    @test 2 == sub2idx("B")
    @test "A" == idx2sub(1)
    @test "B" == idx2sub(2)
  end

  @testset "Any" begin
    (n, sub2idx, idx2sub) = getconv(s2)
    @test n == 3
    @test 1 == sub2idx(:x)
    @test 2 == sub2idx(:y)
    @test 3 == sub2idx('3')
    @test :x  == idx2sub(1)
    @test :y  == idx2sub(2)
    @test '3' == idx2sub(3)
  end

  let
    (n, sub2idx, idx2sub) = getconv(s3)
    @test n == 6
    for idx in 1:n
      sub = idx2sub(idx)
      idx2 = sub2idx(sub...)
      @test idx == idx2
    end
  end
end
