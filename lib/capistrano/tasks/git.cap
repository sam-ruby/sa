namespace 'git' do
  task 'check' do
     if fetch(:stage) == :development
       ask :branch, :develop
       puts "You entered #{fetch(:branch)}. Continue ?"
       ask 'Y/n', :Y
       exit unless fetch('Y/n') =~ /y+/i
     elsif fetch(:stage) == :production
       ask :branch, proc { `git tag`.split("\n").last }   
       puts "You entered #{fetch(:branch)}. Continue ?"
       ask 'Y/n', :Y
       exit unless fetch('Y/n') =~ /y+/i
     end
  end
end
