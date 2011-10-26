directory 'output'
task 'compile'  => 'output' do
  sh 'coffee --bare -o output -c lib/jquery.livepopup.coffee'
end

task 'clean' do
  rm_rf 'output/*'
end

task :default => :compile
