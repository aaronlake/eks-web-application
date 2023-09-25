set dotenv-load

default: check

init:
  rm -rf .git README.md
  find ./ -type d -name ".terraform" | xargs rm -rf
  find ./ -type f -name ".terraform.lock.hcl" | xargs rm
  git init
  pre-commit install

check:
  pre-commit run --all-files
