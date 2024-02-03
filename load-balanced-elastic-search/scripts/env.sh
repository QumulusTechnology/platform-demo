#!/bin/sh

# env.sh

# Change the contents of this output to get the environment variables
# of interest. The output must be valid JSON, with strings for both
# keys and values.
cat <<EOF
{
  "os_auth_url": "$OS_AUTH_URL",
  "os_project_name": "$OS_PROJECT_NAME"
}
EOF
