def max(array)
  array.max
end

def min(array)
  array.min
end

def avg(array)
  array.reduce(&:+) / array.length.to_f
end

def variance(array)
  mean = avg(array)

  array.reduce { |acc, n| +(n - mean)**2 } / (array.length - 1)
end

def stddev(array)
  Math.sqrt(variance(array))
end

def margin_of_error(array)
  stddev(array) / Math.sqrt(array.length)
end

def bench
  t1 = Time.now
  result = yield
  t2 = Time.now

  (t2 - t1) * 1000
end
