require "spec_helper"

describe Fontcustom::Generator::Template do
  subject do 
    base = Fontcustom::Base.new.load :input_dir => fixture("vectors"), :output_dir => fixture("mixed-output")
    Fontcustom::Generator::Template.new base
  end

  context "#initialize" do
    it "should raise error if not passed options" do
      expect { Fontcustom::Generator::Template.new }.to raise_error(ArgumentError)
      expect { subject }.to_not raise_error(ArgumentError)
    end
  end

  context "#start" do
    it "should raise error if no templates are specified" do
      base = Fontcustom::Base.new.load :templates => []
      no_templates = Fontcustom::Generator::Template.new base
      expect { no_templates.start }.to raise_error Thor::Error, /No templates/
    end
  end

  context "#template_paths" do
    it "should convert symbols to correct paths" do 
      # TODO update this once additional templates are added
      templates = [:scss, :html]
      base = Fontcustom::Base.new.load :templates => templates
      generator = Fontcustom::Generator::Template.new base
      paths = generator.send :template_paths
      paths[0].should =~ /_fontcustom\.scss/
      paths[1].should =~ /fontcustom\.html/
    end
  end

  context "#generate" do
    it "should run Fontcustom.templates for each template" do
      templates = [:scss, :html]
      base = Fontcustom::Base.new.load :templates => templates
      generator = Fontcustom::Generator::Template.new base
      paths = generator.send :template_paths
      base.stub :copy_template
      base.stub :update_data_file
      base.should_receive(:copy_template).twice.with(/fontcustom\./, /fontcustom\./)
      generator.send :generate, paths
    end

    it "should update .fontcustom-data with any files created" do
      templates = [:scss, :html]
      base = Fontcustom::Base.new.load :templates => templates
      generator = Fontcustom::Generator::Template.new base
      paths = generator.send :template_paths
      base.stub :copy_template
      base.stub :update_data_file
      base.should_receive(:update_data_file).once.with(base.opts.output_dir, ["_fontcustom.scss", "fontcustom.html"])
      generator.send :generate, paths
    end
  end
end