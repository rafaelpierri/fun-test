guard 'rspec', cmd: "bin/rspec" do
  # watch /lib/ files
  watch(%r{^lib/(.+).rb$}) do |m|
    "spec/pdf_ecad_spec.rb"
  end
 
# watch /spec/ files
  watch(%r{^spec/(.+).rb$}) do |m|
    "spec/#{m[1]}.rb"
  end
end
