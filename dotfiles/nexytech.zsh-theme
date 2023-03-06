PROMPT='%F{white}%2c%(?:%{$fg[green]%} [ :%{$fg[red]%} [ )'

RPROMPT='$(git_prompt_info) %(?:%{$fg[green]%} ]:%{$fg[red]%} ]) %F{green}%D{%L:%M} %F{yellow}%D{%p}%f'

ZSH_THEME_GIT_PROMPT_PREFIX="%F{yellow}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
ZSH_THEME_GIT_PROMPT_DIRTY=" %F{red}*%f"
ZSH_THEME_GIT_PROMPT_CLEAN=""
