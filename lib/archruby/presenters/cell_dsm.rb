class CellDSM

  attr_reader :type
  #attr_reader :how_many_access

  def initialize(how_many_access, type)
    @how_many_access = how_many_access
    @type = type
  end

  def how_many_access()
    if(@type.eql?"allowed")
      return "#{@how_many_access}"
    elsif(@type.eql?"divergence")
      return "#{@how_many_access}"
    else(@type.eql?"absense")
      return "#{@how_many_access}"
    end
  end
end
