#!/usr/bin/env bash

create_hook_success () {
    echo -e "#!/usr/bin/env bash\necho Good\nexit 0" > .git/hooks/$1-stream-$2-$3
    chmod +x .git/hooks/$1-stream-$2-$3
}

create_hook_failure() {
    echo -e "#!/usr/bin/env bash\necho Bad\nexit 1" > .git/hooks/$1-stream-$2-$3
    chmod +x .git/hooks/$1-stream-$2-$3
}
