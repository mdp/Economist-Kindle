class Responder < TrueClass

  def foo
    p 'test'
  end

end

r = Responder
if r == true
  p r.foo
end
