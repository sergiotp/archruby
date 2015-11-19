class CellDSM

  attr_reader :type
  attr_reader :how_many_access

  def initialize(how_many_access, type)
    @how_many_access = how_many_access
    @type = type
  end

  def how_many_access_with_font
    font = 
      if how_many_access >= 1000
        "<font size='1'>#{@how_many_access}<font>"
      elsif how_many_access >= 100
        "<font size='2'>#{@how_many_access}<font>"
      else
        "#{@how_many_access}"
      end
    font
  end

end
