class JumpConsistentHash
  # Implements jump consistent hash
  # from http://arxiv.org/ftp/arxiv/papers/1406/1406.2294.pdf

  def initialize(n)
    @buckets = n
  end

  K2 = 1 << 31
  PR_MUL = 2862933555777941757
  B64 = (1 << 64) - 1

  def bucket(key)
    b = nil
    j = 0
    while j < @buckets
      b = j
      key = (key * PR_MUL + 1) & B64
      j = ((b + 1) * K2 / ((key >> 33) + 1).to_f).to_i
    end
    b
  end
end
