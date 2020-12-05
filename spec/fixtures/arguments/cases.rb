module ArgumentTests
  def self.named(args)
    args = args.map do |(arg, value)|
      "--#{arg} #{value}"
    end

    ["optional-named-arguments-test", args].flatten.join " "
  end

  def self.switch(*args)
    args = args.map {|arg| "--#{arg}"}

    ["switch-arguments-test", args].flatten.join " "
  end

  def self.assert_instance_variable_wiring!(plugin, *args)
    args.map(&:to_s).each do |name|
      raise "@#{name} is not equal to args.#{name}" unless plugin.instance_variable_get("@#{name}") == plugin.args.send(name.to_s)
    end
  end
end