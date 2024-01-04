_fzf_complete_kubectl() {
  local resource_list
  resource_list=$(kubectl get pods -o=jsonpath='{range .items[*]}{@.metadata.name}{"\n"}{end}' | tr ' ' '\n') 
  _fzf_complete --multi --reverse --prompt="pods> " -- "$@" < <(
    echo ${resource_list} | tr ' ' '\n'
  )
}

complete -F _fzf_complete_kubectl -o default -o bashdefault kubectl