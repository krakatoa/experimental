Experimental projects just for learning cool things :)
=============-==_+-===-=_-==========================

To download a project, use the following bash command by replacing the PROJECT with a repo subfolder,

curl -L https://raw.github.com/krakatoa/experimental/master/bootstrap.sh | bash -s PROJECT

It will mkdir "krakatoa-experimental" and will put just the content of named PROJECT inside (by using the git sparse command)

So for example, using the following to download the "c/cpu_info" project:

curl -L https://raw.github.com/krakatoa/experimental/master/bootstrap.sh | bash -s c/cpu_info

Will create krakatoa-experimental, and it will have the c/cpu_info tree inside of it.

:)
