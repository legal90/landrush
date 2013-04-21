require 'test_helper'
require 'vagrant-rubydns/action/teardown'

module VagrantRubydns
  module Action
    describe Teardown do
      it "calls the next app in the chain" do
        env = fake_environment(called: false)

        app = lambda { |e| e[:called] = true }

        teardown = Teardown.new(app, nil)
        teardown.call(env)

        env[:called].must_equal true
      end

      it "clears the machine's hostname => ip address" do
        Store.set('somehost.vagrant.dev', '1.2.3.4')

        app = Proc.new {}
        teardown = Teardown.new(app, nil)

        env = fake_environment_with_machine('somehost.vagrant.dev', '1.2.3.4')
        teardown.call(env)

        Store.get('somehost.vagrant.dev').must_equal nil
      end

      it "does nothing when rubydns is disabled" do
        # somewhat unrealistic since this entry shouldn't be there if it was
        # disabled in the first place, but oh well
        Store.set('somehost.vagrant.dev', '1.2.3.4')

        app = Proc.new {}
        teardown = Teardown.new(app, nil)

        env = fake_environment_with_machine('somehost.vagrant.dev', '1.2.3.4')
        env[:global_config].rubydns.disable

        teardown.call(env)

        Store.get('somehost.vagrant.dev').must_equal '1.2.3.4'
      end
    end
  end
end

