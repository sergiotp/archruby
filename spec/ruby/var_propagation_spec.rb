require 'spec_helper'

describe Archruby::Ruby::VarPropagation do
  it 'storage var propagation correctly' do
    var_propagation = Archruby::Ruby::VarPropagation.new
    var_propagation.push :a, 1, "ClassTeste"
    var_propagation.push :a, 2
    var_propagation.push :a, 3
    var_propagation.vars.first[:a][:lines].count.should be_eql(3)
  end

  it 'put type correctly' do
    var_propagation = Archruby::Ruby::VarPropagation.new
    var_propagation.push :a, 1
    var_propagation.put_type :a, "Teste"
    var_propagation.vars.first[:a][:type].should be_eql("Teste")

    var_propagation.push :b, 1
    var_propagation.put_type :b, "Teste2"
    var_propagation.vars.last[:b][:type].should be_eql("Teste2")
  end
end
