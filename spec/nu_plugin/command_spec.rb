require 'nu_plugin/command'

def create_named(options={})
  NuPlugin::Command::OptionalFlag.build(options)
end

def named(command)
  command.configuration[:named]
end

describe NuPlugin::Command do
  context 'optional named flags' do
    it 'can have short' do
      class OptionalNamedFlagDSLShortNameTest < NuPlugin::Command
        optional :arg, short: 'a'
      end

      expected = create_named(short: 'a')
      flags = named(OptionalNamedFlagDSLShortNameTest.new)
      expect(flags[:arg]).to eq(expected)
    end

    it 'can have description' do
      class OptionalNamedFlagDSLDescriptionTest < NuPlugin::Command
        optional :arg, desc: 'gallinas'
      end

      expected = create_named(desc: 'gallinas')
      flags = named(OptionalNamedFlagDSLDescriptionTest.new)
      expect(flags[:arg]).to eq(expected)
    end

    it 'can have row argument' do
      class RowArgumentTest < NuPlugin::Command
        optional :arg, type: Array
      end

      expected = create_named(type: Array)
      flags = named(RowArgumentTest.new)
      expect(flags[:arg]).to eq(expected)
    end

    it 'can have string argument' do
      class StringArgumentTest < NuPlugin::Command
        optional :arg, type: String
      end

      expected = create_named(type: String)
      flags = named(StringArgumentTest.new)
      expect(flags[:arg]).to eq(expected)
    end
  end

  context 'configuration' do
    it 'can have a name' do
      class NameTest < NuPlugin::Command
        name 'test_command'
      end

      expect(NameTest.new.configuration[:name]).to eq('test_command')
    end

    it 'can have named flag' do
      class FlagTest < NuPlugin::Command
        flag 'load' => create_named(type: String, desc: 'sample')
      end

      expected = create_named(type: String, desc: 'sample')
      flags = named(FlagTest.new)

      expect(flags.keys).to include('load')
      expect(flags['load']).to eq(expected)
    end

    it 'can have many named flags' do
      class NamedFlagsTest < NuPlugin::Command
        flag 'arg1' => create_named(type: String, desc: 'first arg')
        flag 'arg2' => create_named(type: String, desc: 'another arg')
      end

      flags = named(NamedFlagsTest.new)
      expect(flags.keys).to eq(%w{arg1 arg2})

      [
        ['arg1', create_named(type: String, desc: 'first arg')],
        ['arg2', create_named(type: String, desc: 'another arg')]
      ].each do |(flag, expected)|
        expect(flags[flag]).to eq(expected)
      end
    end

    context 'filter command' do
      it "infers it's a filter by the presence of filter!" do
        class FilterTypeTest < NuPlugin::Command
          def filter(params); end
        end

        expect(FilterTypeTest.new.configuration[:is_filter]).to be(true)
      end

      it 'can set before action' do
        class BeforeFilterTest < NuPlugin::Command
          before_action :ping

          def ping
            'pong'
          end
        end

        action = BeforeFilterTest.instance_variable_get('@before')
        expect(BeforeFilterTest.new.send(action)).to eq('pong')
      end

      it 'can set after action' do
        class AfterFilterTest < NuPlugin::Command
          after_action :ping

          def ping
            'pong'
          end
        end

        action = AfterFilterTest.instance_variable_get('@after')
        expect(AfterFilterTest.new.send(action)).to eq('pong')
      end
    end

    context 'sink command' do
      it "infers it's a sink by the presence of sink!" do
        class SinkTypeTest < NuPlugin::Command
          def sink(params); end
        end

        expect(SinkTypeTest.new.configuration[:is_filter]).to be(false)
      end
    end
  end
end
