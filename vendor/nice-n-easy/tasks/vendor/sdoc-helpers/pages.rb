namespace :pages do
  task :publish => [ :check_dirty, :rerdoc ] do
    `git checkout gh-pages`
    `ls -1 | grep -v docs | xargs rm -rf; mv docs/* .; rm -rf docs`
    `git add .; git commit -m "update docs"; git push origin gh-pages`
    `git checkout master`
    puts :done
  end

  desc "Initialize GitHub Pages with documentation"
  task :init => [ :check_dirty, :rerdoc ] do
    `git symbolic-ref HEAD refs/heads/gh-pages`
    `rm .git/index`
    `ls -1 | grep -v docs | xargs rm -rf; mv docs/* .; rm -rf docs`
    `git add .;git commit -m "create docs"; git push origin gh-pages`
    `git checkout master`
    puts :done
  end

  task :check_dirty do
    if !`git status`.include?('nothing to commit')
      abort "dirty index - not publishing!"
    end
  end
end

desc "Build and publish documentation using GitHub Pages."
task :pages => "pages:publish"
