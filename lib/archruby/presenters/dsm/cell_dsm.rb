class CellDSM

  attr_reader :type
  attr_reader :how_many_access

  def initialize(how_many_access, type)
    @how_many_access = how_many_access
    @type = type
  end

end
