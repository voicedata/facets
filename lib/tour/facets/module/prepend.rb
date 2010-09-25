module Prependable

  def self.included(base)
    base.extend Self
    base.instance_methods(false).each do |meth|
      base.method_added(meth)
    end
  end

  module Self
    def prepend_module
      @_prepend_module ||= Module.new
    end

    def method_added(meth)
      return if meth.to_s[-2,2] == ':-'
      alias_method "#{meth}:-", meth
      remove_method(meth)
      prepend_module.module_eval %{
        def #{meth}(*a,&b); __send__("#{meth}:-",*a,&b); end
      }
      include prepend_module
    end
  end

end

class Module

  # Prepend module.
  #
  #   class X
  #     def a; "Xa"; end
  #   end
  #
  #   module M
  #     def a; "M" + super ; end
  #   end
  #
  #   class X
  #     prepend M
  #   end
  #
  #   X.new.a  #=> MXa
  #
  def prepend(mod)
    include Prependable
    include mod
  end

end

