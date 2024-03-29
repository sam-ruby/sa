Rake::Task['db:migrate'].clear
Rake::Task['db:abort_if_pending_migrations'].clear
namespace 'db' do
  desc 'Migration scripts are not needed in cad'
  task 'migrate' do
    puts 'Migration task has been overridden to do nothing since this is a read only DB.'
  end

  desc 'Overriding the task abort_if_pending_migrations'
  task 'abort_if_pending_migrations' do
    puts 'db:abort_if_pending_migrations has been overridden to do nothing.'
  end
end
