# Copyright 2018 Artem Artemyev
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

function _get_commands_files {
        local -a files
        local -a local_commands_files
        local global_commands_file default_commands_file
        
        default_commands_file="$HOME/.commands.json"
        global_commands_file="${ZZZ_COMMANDS_FILE:-$default_commands_file}"

        if [[ -s $global_commands_file ]]; then
                files+=$global_commands_file
        fi

        local_commands_files=($(echo (../)#.commands.json(N:a)))

        for file in ${local_commands_files[@]}; do
                if [[ -s $file ]]; then
                        files+=$file
                fi
        done

        echo ${(u)files[@]}
}

function _get_jq_path {
        local -a arguments
        local json_path

        arguments=($@)

        if [ ${#arguments[@]} -eq 0 ]; then
                json_path="."
        else
                local -a args_with_dot
                
                for i in ${arguments[@]}; do
                        args_with_dot+=".$i"
                done

                json_path=". | ${(j: | :)args_with_dot}"
        fi

        echo $json_path
}

function _get_jq_merge_function {
        local -a parts

        for ((i = 0; i < $1; i++)); do
                parts+=".[$i]"
        done

        echo "${(j: * :)parts}"
}

function _get_args {
        local -a result
        local -a command_files
        
        command_files=($(_get_commands_files))

        if [ ${#command_files[@]} -eq 0 ]; then
                echo ""
        else
                cmd="$(which jq) -s -r '$(_get_jq_merge_function ${#command_files[@]}) | $(_get_jq_path $@) | keys | .[]' ${command_files[@]}"
                result=("${(@f)$(eval $cmd 2>/dev/null)}")
                
                echo $result
        fi
}

function _get_cmd {
        local result
        local -a command_files
        
        command_files=($(_get_commands_files))
 
        if [ ${#command_files[@]} -eq 0 ]; then
                echo ""
        else
                cmd="$(which jq) -s -r '$(_get_jq_merge_function ${#command_files[@]}) | $(_get_jq_path $@)' ${command_files[@]}"
                result="$(eval $cmd 2>/dev/null)"
                
                echo $result
        fi       
}

function _get_zzz_comp {
        local -a args
        
        args=($(_get_args ${words[@]:1}))

        _describe -t commands "commands" args
}

function zzz {
        local cmd
        
        cmd=$(_get_cmd $@)
        
        echo $cmd
        eval $cmd
}

if ! jq_loc="$(type -p "$(which jq)")" || [[ -z $jq_loc ]]; then
        echo "jq is required for zzz completion. Please install jq"
else
        compdef _get_zzz_comp zzz
fi
